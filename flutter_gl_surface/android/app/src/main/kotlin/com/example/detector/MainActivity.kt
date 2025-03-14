package com.example.detector

import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import android.Manifest
import android.os.Build
import android.util.Log
import android.view.Surface
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking

class MainActivity: FlutterActivity() {
    private lateinit var methodChannel: MethodChannel
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (hasPermissions(this)) {
            // If permissions have already been granted, proceed
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                requestPermissions(PERMISSIONS_REQUIRED, PERMISSIONS_REQUEST_CODE)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val surfaceFactory = MyGLSurfaceViewFactory(flutterEngine.dartExecutor.binaryMessenger, null)
        val registry: PlatformViewRegistry = flutterEngine.platformViewsController.registry
        registry.registerViewFactory("my_gl_surface_view", surfaceFactory)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "main/cmd")

        methodChannel.setMethodCallHandler { call, result ->
                try {
                    val args = call.arguments as HashMap<*, *>
                    when (call.method) {
                        "register_view" -> {
                            result.success(true)
                        }
                        "get_device_sensor" -> {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                context.display?.rotation?.let {
                                    when (it) {
                                        Surface.ROTATION_0 -> result.success(0)
                                        Surface.ROTATION_90 -> result.success(90)
                                        Surface.ROTATION_180 -> result.success(180)
                                        Surface.ROTATION_270 -> result.success(270)
                                    }
                                }
                            } else {
                                activity.windowManager?.getDefaultDisplay()?.rotation?.let {
                                    when (it) {
                                        Surface.ROTATION_0 -> result.success(0)
                                        Surface.ROTATION_90 -> result.success(90)
                                        Surface.ROTATION_180 -> result.success(180)
                                        Surface.ROTATION_270 -> result.success(270)
                                    }
                                }
                            }
                        }
                        "start_camera" -> {
                            runBlocking(Dispatchers.IO) {
                                val id = args["id"] as String
                                val minArea = args["minArea"] as Int
                                val captureIntervalSec = args["captureIntervalSec"] as Int
                                val showAreaOnCapture = args["showAreaOnCapture"] as Boolean
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                val size = captureRep?.start(id, minArea, captureIntervalSec, showAreaOnCapture)
                                result.success(mapOf(
                                    "size_width" to size?.width,
                                    "size_height" to size?.height))
                            }
                        }
                        "stop_camera" -> {
                            runBlocking(Dispatchers.IO) {
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.stop()
                                result.success(true)
                            }
                        }
                        "set_capture_active" -> {
                            runBlocking(Dispatchers.IO) {
                                val active = args["active"] as Boolean
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.setCaptureActive(active)
                                result.success(true)
                            }
                        }
                        "capture_one_frame" -> {
                            runBlocking(Dispatchers.IO) {
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.captureOneFrameNative(args["service_frame"] as Boolean)
                                result.success(true)
                            }
                        }
                        "update_configuration" -> {
                            runBlocking(Dispatchers.IO) {
                                val minArea = args["minArea"] as Int
                                val captureIntervalSec = args["captureIntervalSec"] as Int
                                val showAreaOnCapture = args["showAreaOnCapture"] as Boolean
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.updateConfiguration(minArea, captureIntervalSec, showAreaOnCapture)
                                result.success(true)
                            }
                        }
                        "get_cameras" -> {
                            runBlocking(Dispatchers.IO) {
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                if (captureRep == null) {
                                    result.error("", "cannot open", "")
                                    return@runBlocking
                                }
                                val cameras = captureRep.getCameras(context)
                                val map = mutableMapOf<String, Any>()
                                for (cameraIndex in cameras.indices) {
                                    val cameraDesc = cameras[cameraIndex]
                                    if (cameraDesc != null) {
                                        val map2 = mutableMapOf<String, Any>()
                                        val camera = cameraDesc.size.lastOrNull()
                                        map2["width"] = camera?.width ?: 0
                                        map2["height"] = camera?.height ?: 0
                                        map2["facing"] = cameraDesc.facing.name
                                        map2["sensor"] = cameraDesc.sensorOrientation
                                        map["$cameraIndex"] = map2
                                    }
                                }
                                result.success(map)
                            }
                        }
                        else -> {
                            result.success(true)
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing", e)
                }
            }

        val captureRep = (context.applicationContext as App?)?.captureRep
        if(captureRep != null) {
            captureRep.setNativeListener(object : NativeListener {
                override fun onCapture(path: String) {
                    runBlocking(Dispatchers.Main) {
                        methodChannel.invokeMethod("onCapture", mapOf("path" to path))
                    }
                }
                override fun onMovement() {
                    runBlocking(Dispatchers.Main) {
                        methodChannel.invokeMethod("onMovement", null)
                    }
                }

                override fun onFirstFrameNotify() {
                    runBlocking(Dispatchers.Main) {
                        methodChannel.invokeMethod("onFirstFrameNotify", null)
                    }
                }
            })
        } else {
            Log.e(TAG, "cannot get capture repository")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        val captureRep = (context.applicationContext as App?)?.captureRep
        captureRep?.setNativeListener(null)
    }

    companion object {
        private val TAG = MainActivity::class.java.simpleName

        fun hasPermissions(context: Context) = PERMISSIONS_REQUIRED.all { it: String ->
            ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }
    }
}

private val PERMISSIONS_REQUEST_CODE = 10
private val PERMISSIONS_REQUIRED = arrayOf(Manifest.permission.CAMERA, Manifest.permission.READ_MEDIA_VIDEO)
