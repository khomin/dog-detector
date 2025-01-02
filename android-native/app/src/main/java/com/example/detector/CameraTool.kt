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
import androidx.core.app.ActivityCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine


enum class CameraFacing { Front, Back }

class CameraDescription(val size: List<Size>, val id: String, val facing: CameraFacing) {}

class CameraTool(val context: Context) {
    var cameraFacing: CameraFacing = CameraFacing.Back
    private var cameraId: String ?=null
    var deviceOrientation = 0
    var sensorOrientation = 0

    private var imageReader: ImageReader? = null
    private var cameraThread: HandlerThread?=null
    private var cameraHandler: Handler?=null
    private var imageReaderThread: HandlerThread?=null
    private var imageReaderHandler: Handler?=null
    private var camera: CameraDevice? = null
    private var session: CameraCaptureSession?=null
    private val coroutineScope = CoroutineScope(Dispatchers.Main)
    private val tag = "CameraTools"

    init {
        cameraThread = HandlerThread("CameraThread").apply { start() }
        cameraHandler = Handler(cameraThread!!.looper)
        imageReaderThread = HandlerThread("imageReaderThread").apply { start() }
        imageReaderHandler = Handler(imageReaderThread!!.looper)
    }

    fun finalize() {
        closeCamera()
    }

    fun closeCamera() {
        try {
            camera?.close()
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

    fun openCamera(id: String, width: Int, height: Int, facing: CameraFacing, context: Context) {
        val manager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            Log.e(tag, "Camera permission is not granted")
            return
        }
        manager.openCamera(id, object : CameraDevice.StateCallback() {
            override fun onOpened(device: CameraDevice) {
                camera = device
                cameraId = id
                cameraFacing = facing
                val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
                // get sensor orientation
                cameraManager.getCameraCharacteristics(id).get(CameraCharacteristics.SENSOR_ORIENTATION)?.let {
                    sensorOrientation = it
                    initSession(Size(width, height))
                    startNative(width, height)
                }
            }
            override fun onDisconnected(device: CameraDevice) {
                Log.w(tag, "Camera $cameraId has been disconnected")
                device.close()
            }
            override fun onError(device: CameraDevice, error: Int) {
                device.close()
            }
        }, cameraHandler)
    }

    fun updateDeviceOrientation(rotation: Int) {
        when (rotation) {
            Surface.ROTATION_0 -> deviceOrientation = 0
            Surface.ROTATION_90 -> deviceOrientation = 90
            Surface.ROTATION_180 -> deviceOrientation = 180
            Surface.ROTATION_270 -> deviceOrientation = 270
        }
    }

    fun getDescription(cameraId: String, context: Context): CameraDescription? {
        try {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val characteristics = cameraManager.getCameraCharacteristics(cameraId)
            val supportedResolutions = mutableListOf<Size>()
            val configurationMap = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
            val facing = characteristics.get(CameraCharacteristics.LENS_FACING)
            configurationMap?.getOutputSizes(ImageFormat.YUV_420_888)?.forEach { size ->
                if(size.width <= 1280) {
                    supportedResolutions.add(size)
                }
            }
            supportedResolutions.sortBy { size: Size -> size.width }
            return CameraDescription(supportedResolutions, cameraId, when (facing) {
                CameraCharacteristics.LENS_FACING_FRONT -> {
                    CameraFacing.Front
                }
                CameraCharacteristics.LENS_FACING_BACK -> {
                    CameraFacing.Back
                }
                else -> {
                    CameraFacing.Back
                }
            })
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return null
    }

    fun getCameras(context: Context): List<CameraDescription?> {
        val cameras = mutableListOf<CameraDescription?>()
        try {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            for(cameraId in cameraManager.cameraIdList) {
                val characteristics = cameraManager.getCameraCharacteristics(cameraId)
                val configurationMap =
                    characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)
                val facing = characteristics.get(CameraCharacteristics.LENS_FACING)
                val supportedResolutions = mutableListOf<Size>()
                configurationMap?.getOutputSizes(ImageFormat.YUV_420_888)?.forEach { size ->
                    if (size.width <= 1280) {
                        supportedResolutions.add(size)
                    }
                }
                supportedResolutions.sortBy { size: Size -> size.width }
                cameras.add(CameraDescription(supportedResolutions, cameraId, when (facing) {
                    CameraCharacteristics.LENS_FACING_FRONT -> {
                        CameraFacing.Front
                    }
                    CameraCharacteristics.LENS_FACING_BACK -> {
                        CameraFacing.Back
                    }
                    else -> {
                        CameraFacing.Back
                    }
                }))
            }
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return cameras
    }

    private fun initSession(frameSize: Size) = coroutineScope.launch(Dispatchers.Main) {
        imageReader = ImageReader.newInstance(
            frameSize.width, frameSize.height, ImageFormat.YUV_420_888, 2
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
                Log.e(tag, exc.message, exc)
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

    external fun genTextureNative() : Long
    external fun updateFrameNative()
    external fun updateViewSizeNative(
        width: Int,
        height: Int,
        sensorOrientation: Int,
        deviceOrientation: Int,
        facing: Int
    )
}