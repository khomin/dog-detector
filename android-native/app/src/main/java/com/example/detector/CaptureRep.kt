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
import android.opengl.GLSurfaceView
import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import android.util.Range
import android.util.Size
import android.view.Surface
import android.view.View
import androidx.core.app.ActivityCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

enum class CameraFacing { Front, Back }

class CameraDescription(val size: List<Size>, val id: String, val facing: CameraFacing, val sensorOrientation: Int) {}

class CaptureRep(val context: Context, val appLocalDir: String) {
    private var cameraDescription: CameraDescription ?= null
    private var cameraSize: Size = Size(0,0)
    private var render: MyRenderer?= null
    private var isRunning = false
    private var cameraFacing: CameraFacing = CameraFacing.Back
    private var deviceOrientation = 0
    private var sensorOrientation = 0
    private var surfaceView: GLSurfaceView ?= null
    private var cameraId: String ?=null
    private var imageReader: ImageReader? = null
    private var cameraThread: HandlerThread?=null
    private var cameraHandler: Handler?=null
    private var imageReaderThread: HandlerThread?=null
    private var imageReaderHandler: Handler?=null
    private var camera: CameraDevice? = null
    private var session: CameraCaptureSession?=null
    private val coroutineScope = CoroutineScope(Dispatchers.Main)
    private val mutex = Mutex()
    val tag = "CaptureRep"

    init {
        cameraThread = HandlerThread("CameraThread").apply { start() }
        cameraHandler = Handler(cameraThread!!.looper)
        imageReaderThread = HandlerThread("imageReaderThread").apply { start() }
        imageReaderHandler = Handler(imageReaderThread!!.looper)

    }

    fun setNativeListener(nativeListener: NativeListener?) {
        setListenerNative(nativeListener)
    }

    suspend fun start(cameraId: String, minArea: Int, captureIntervalSec: Int, showAreaOnCapture: Boolean): Size {
        stop()
        mutex.withLock {
            val desc = getDescription(cameraId, context)
            if (desc == null) {
                Log.e(tag, "camera info is null")
                return Size(0, 0)
            }
            isRunning = true
            cameraDescription = desc
            cameraSize = desc.size.lastOrNull() ?: return Size(0, 0)
            openCamera(
                cameraId,
                cameraSize.width,
                cameraSize.height,
                desc.facing,
                minArea,
                captureIntervalSec,
                showAreaOnCapture,
                context
            )
            return Size(cameraSize.width, cameraSize.height)
        }
    }

    suspend fun stop() {
        stopCamera()
        isRunning = false
    }

    fun setCaptureActive(active: Boolean) {
        setCaptureActiveNative(active)
    }

    suspend fun updateConfiguration(minArea: Int, captureIntervalSec: Int, showAreaOnCapture: Boolean) {
        mutex.withLock {
            try {
                if(isRunning) {
                    updateConfigurationNative(minArea, captureIntervalSec, showAreaOnCapture)
                }
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
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
                val orientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 0
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
                }, orientation))
            }
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return cameras
    }

    private suspend fun stopCamera() {
        mutex.withLock {
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
    }

    private fun openCamera(id: String, width: Int, height: Int, facing: CameraFacing, minArea: Int, captureIntervalSec: Int, showAreaOnCapture: Boolean, context: Context) {
        val manager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.e(tag, "Camera permission is not granted")
            return
        }
        manager.openCamera(id, object : CameraDevice.StateCallback() {
            override fun onOpened(device: CameraDevice) {
                camera = device
                cameraId = id
                cameraFacing = facing
                val cameraManager =
                    context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
                // get sensor orientation
                cameraManager.getCameraCharacteristics(id)
                    .get(CameraCharacteristics.SENSOR_ORIENTATION)?.let {
                        sensorOrientation = it
                        coroutineScope.launch(Dispatchers.Main) {
                            try {
                                imageReader = ImageReader.newInstance(
                                    width, height, ImageFormat.YUV_420_888, 2
                                )
                                val imageReaderSafe = imageReader ?: return@launch
                                val cameraSafe = camera ?: return@launch
                                val targets = listOf(imageReaderSafe.surface)

                                session = createCaptureSession(cameraSafe, targets, cameraHandler)

                                var yPlaneBuffer = ByteArray(0)
                                var uPlaneBuffer = ByteArray(0)
                                var vPlaneBuffer = ByteArray(0)

                                imageReaderSafe.setOnImageAvailableListener({ reader ->
                                    val i: Image? = reader.acquireLatestImage()
                                    if (i != null) {
                                        try {
                                            val planes: Array<Image.Plane> = i.planes
                                            // init buffers first time
                                            if (yPlaneBuffer.isEmpty()) {
                                                yPlaneBuffer =
                                                    ByteArray(planes[0].buffer.remaining())
                                            }
                                            if (uPlaneBuffer.isEmpty()) {
                                                uPlaneBuffer =
                                                    ByteArray(planes[1].buffer.remaining())
                                            }
                                            if (vPlaneBuffer.isEmpty()) {
                                                vPlaneBuffer =
                                                    ByteArray(planes[2].buffer.remaining())
                                            }
                                            // Use existing buffers
                                            planes[0].buffer.get(yPlaneBuffer)
                                            planes[1].buffer.get(uPlaneBuffer)
                                            planes[2].buffer.get(vPlaneBuffer)

                                            putFrameNative(
                                                yPlaneBuffer,
                                                planes[0].rowStride,
                                                uPlaneBuffer,
                                                planes[1].rowStride,
                                                vPlaneBuffer,
                                                planes[2].rowStride,
                                                planes[1].pixelStride,
                                                i.width,
                                                i.height
                                            )
                                        } catch (ex: Exception) {
                                            ex.printStackTrace()
                                        } finally {
                                            i.close() // Make sure to close in finally to ensure it gets called
                                        }
                                    }
                                }, imageReaderHandler)

                                val captureRequest = session?.device?.createCaptureRequest(
                                    CameraDevice.TEMPLATE_PREVIEW
                                )?.apply {
                                    addTarget(imageReaderSafe.surface)
                                }
                                if (captureRequest != null) {
                                    val fpsRange: Range<Int> = Range(20, 25)
                                    captureRequest.set(
                                        CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE,
                                        fpsRange
                                    )
                                    session?.setRepeatingRequest(
                                        captureRequest.build(),
                                        captureCallback,
                                        cameraHandler
                                    )
                                }
                                startNative(
                                    width,
                                    height,
                                    minArea,
                                    captureIntervalSec,
                                    showAreaOnCapture,
                                    appLocalDir
                                )
                            } catch (ex: Exception) {
                                Log.e(tag, ex.message, ex)
                            }
                        }
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
            session: CameraCaptureSession, request: CaptureRequest, result: TotalCaptureResult
        ) {}
    }

    private fun getDescription(cameraId: String, context: Context): CameraDescription? {
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
            val orientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION) ?: 0
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
            }, orientation)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        return null
    }

    private external fun startNative(width: Int,  height: Int, minArea: Int, captureIntervalSec: Int, showAreaOnCapture: Boolean, appLocalDir: String)
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
    external fun setCaptureActiveNative(active: Boolean)
    external fun captureOneFrameNative()
    external fun updateViewSizeNative(
        width: Int,
        height: Int,
        sensorOrientation: Int,
        deviceOrientation: Int,
        facing: Int
    )
    external fun setListenerNative(listener: NativeListener?)
    external fun updateConfigurationNative(minArea: Int, captureIntervalSec: Int, showAreaOnCapture: Boolean)

    fun initRender(surfaceView: GLSurfaceView) {
        this.surfaceView = surfaceView
        render = MyRenderer(genTexture = {
            genTextureNative()
        }, updateFrame = {
            updateFrameNative()
        }, onUpdateSize = { surfaceSize ->
            updateViewSizeNative(
                surfaceSize.width, surfaceSize.height,
                sensorOrientation,
                deviceOrientation,
                cameraFacing.ordinal
            )
        })
        surfaceView.visibility = View.VISIBLE
        surfaceView.setEGLContextClientVersion(2)
        surfaceView.setRenderer(render)
    }

    fun cleanRender() {
        surfaceView?.onPause()
        surfaceView?.holder?.surface?.release()
        surfaceView = null
        render = null
    }

    fun reinit() {
        if(isRunning) {
            surfaceView?.visibility = View.VISIBLE
//            surfaceView?.setEGLContextClientVersion(2)
//            surfaceView?.setRenderer(render)
        }
    }
}