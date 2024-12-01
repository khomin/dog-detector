package com.example.detector

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.ImageFormat
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CaptureRequest
import android.hardware.camera2.TotalCaptureResult
import android.media.Image
import android.media.ImageReader
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.util.Range
import android.util.Size
import android.view.Surface
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine


class CameraTools(val context: Context, val windowManager: WindowManager) {
    private var cameraId: String ?=null
    private var imageReader: ImageReader? = null
    private var cameraThread: HandlerThread?=null
    private var cameraHandler: Handler?=null
    private var imageReaderThread: HandlerThread?=null
    private var imageReaderHandler: Handler?=null
    private var camera: CameraDevice? = null
    private var session: CameraCaptureSession?=null
    private val IMAGE_BUFFER_SIZE: Int = 2
    private val coroutineScope = CoroutineScope(Dispatchers.Main)
    private val TAG = "CameraTools"

    init {
        cameraThread = HandlerThread("CameraThread").apply { start() }
        cameraHandler = Handler(cameraThread!!.looper)
        imageReaderThread = HandlerThread("imageReaderThread").apply { start() }
        imageReaderHandler = Handler(imageReaderThread!!.looper)
    }

    fun finalize() {
        imageReader?.close()
        cameraThread?.quitSafely()
        imageReaderThread?.quitSafely()
        camera?.close()
        session?.close()
        imageReader = null
        cameraThread = null
        cameraHandler = null
        imageReaderThread = null
        imageReaderHandler = null
        camera = null
        session = null
    }

    fun closeCamera() {
        try {
            session?.stopRepeating()
            session?.abortCaptures()
            session?.close()
            imageReader?.close()
            session = null
            imageReader = null
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        stopNative()
    }

    fun openCamera(id: String, width: Int, height: Int, context: Context) {
        val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        startNative(width, height)
        camera = openCamera(cameraManager, id, cameraHandler)
        if (camera != null) {
            initializeCamera(Size(width, height))
            cameraId = id
        }
    }

    fun getDeviceOrientation(): Int {
        val rotation: Int = windowManager.getDefaultDisplay().rotation
        var orientation = 0
        when (rotation) {
            Surface.ROTATION_0 -> orientation = 0
            Surface.ROTATION_90 -> orientation = 90
            Surface.ROTATION_180 -> orientation = 180
            Surface.ROTATION_270 -> orientation = 270
        }
        return orientation
    }

    fun getOrientation(): Int {
        cameraId?.let {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val orientation = cameraManager.getCameraCharacteristics(it).get(CameraCharacteristics.SENSOR_ORIENTATION)
            return orientation ?: 0
        }
        return 0
    }

    fun getCameraSize(cameraId: String, context: Context): List<Size> {
        try {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val characteristics = cameraManager.getCameraCharacteristics(cameraId)
            val supportedResolutions = mutableListOf<Size>()
            val configurationMap = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
            configurationMap?.getOutputSizes(ImageFormat.YUV_420_888)?.forEach { size ->
                // Check minimum frame duration
                val minFrameDuration = configurationMap.getOutputMinFrameDuration(ImageFormat.YUV_420_888, size)
                // Calculate if 30 FPS is supported (1s / 30fps = 33.33ms per frame)
                val supports30Fps = minFrameDuration > 0 && (1e9 / minFrameDuration) >= 30
                // Add to list
                if(supports30Fps && size.width <= 1280) {
                    supportedResolutions.add(size)
                }
            }
            supportedResolutions.sortBy { size: Size -> size.width }
            return supportedResolutions
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return emptyList()
    }

    private fun initializeCamera(size: Size) = coroutineScope.launch(Dispatchers.Main) {
        imageReader = ImageReader.newInstance(
            size.width, size.height, ImageFormat.YUV_420_888, IMAGE_BUFFER_SIZE
        )
        val imageReaderSafe = imageReader ?: return@launch
        val cameraSafe = camera ?: return@launch
        val targets = listOf(imageReaderSafe.surface)

        session = createCaptureSession(cameraSafe, targets, cameraHandler)

        imageReaderSafe.setOnImageAvailableListener({ reader ->
            val i: Image? = reader.acquireLatestImage()
            if (i != null) {
                // yuv420 to argb in cpp
                try {
                    val planes: Array<Image.Plane> = i.planes
                    var buffer = planes[0].buffer
                    val yPlane = ByteArray(planes[0].buffer.remaining())
                    buffer[yPlane]

                    buffer = planes[1].buffer
                    val uPlane = ByteArray(planes[1].buffer.remaining())
                    buffer[uPlane]

                    buffer = planes[2].buffer
                    val vPlane = ByteArray(planes[2].buffer.remaining())
                    buffer[vPlane]

                    val yRowStride = planes[0].rowStride
                    val uvRowStride = planes[1].rowStride
                    val vRowStride = planes[2].rowStride
                    val uvPixelStride = planes[1].pixelStride
                    val width = i.width
                    val height = i.height
                    putFrameNative(
                        yPlane,
                        yRowStride,
                        uPlane,
                        uvRowStride,
                        vPlane,
                        vRowStride,
                        uvPixelStride,
                        width,
                        height
                    )
                } catch (ex: Exception) {
                    ex.printStackTrace()
                }
            }
            i?.close()
        }, imageReaderHandler)

        val captureRequest = session?.device?.createCaptureRequest(
            CameraDevice.TEMPLATE_RECORD
        )?.apply {
            addTarget(imageReaderSafe.surface)
        }
        if (captureRequest != null) {
            val fpsRange: Range<Int> = Range(25, 25)
            captureRequest.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, fpsRange)
            session?.setRepeatingRequest(captureRequest.build(), captureCallback, cameraHandler)
        }
    }

    private fun openCamera(
        manager: CameraManager, cameraId: String, handler: Handler? = null
    ): CameraDevice? {
        var foundDevice: CameraDevice? = null
        var failed = false
        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return null
        }
        manager.openCamera(cameraId, object : CameraDevice.StateCallback() {
            override fun onOpened(device: CameraDevice) {
                foundDevice = device
            }

            override fun onDisconnected(device: CameraDevice) {
                Log.w(TAG, "Camera $cameraId has been disconnected")
            }

            override fun onError(device: CameraDevice, error: Int) {
                failed = true
            }
        }, handler)
        val startTime = System.currentTimeMillis()
        val waitTime: Long = 10000
        val endTime = startTime + waitTime
        while (System.currentTimeMillis() < endTime) {
            if (foundDevice != null || failed) {
                break
            }
            Thread.sleep(50)
        }
        return foundDevice
    }

    /**
     * Starts a [CameraCaptureSession] and returns the configured session (as the result of the
     * suspend coroutine
     */
    private suspend fun createCaptureSession(
        device: CameraDevice, targets: List<Surface>, handler: Handler? = null
    ): CameraCaptureSession = suspendCoroutine { cont ->
        // Create a capture session using the predefined targets; this also involves defining the
        // session state callback to be notified of when the session is ready
        device.createCaptureSession(targets, object : CameraCaptureSession.StateCallback() {
            override fun onConfigured(session: CameraCaptureSession) = cont.resume(session)
            override fun onConfigureFailed(session: CameraCaptureSession) {
                val exc = RuntimeException("Camera ${device.id} session configuration failed")
                Log.e(TAG, exc.message, exc)
                cont.resumeWithException(exc)
            }
        }, handler)
    }

    private val captureCallback = object : CameraCaptureSession.CaptureCallback() {
        override fun onCaptureCompleted(
            session: CameraCaptureSession, request: CaptureRequest, result: TotalCaptureResult) {}
    }

    private external fun startNative(width: Int,  height: Int)
    private external fun stopNative()

    private external fun putFrameNative(
        yPlane: ByteArray?,
        yRowStride: Int,
        uPlane: ByteArray?,
        uRowStride: Int,
        vPlane: ByteArray?,
        vRowStride: Int,
        uvRowStride: Int,
        width: Int,
        height: Int
    )

    external fun genTexture() : Long
    external fun updateFrame()
    external fun updateViewSize(
        width: Int,
        height: Int,
        sensorOrientation: Int,
        deviceOrientation: Int
    )
}