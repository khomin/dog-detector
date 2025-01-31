package com.who.zone

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.Surface
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
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
                            CoroutineScope(Dispatchers.IO).launch {
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
                            CoroutineScope(Dispatchers.IO).launch {
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.stop()
                                result.success(true)
                            }
                        }
                        "set_capture_active" -> {
                            CoroutineScope(Dispatchers.IO).launch {
                                val active = args["active"] as Boolean
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.setCaptureActive(active)
                                result.success(true)
                            }
                        }
                        "capture_one_frame" -> {
                            CoroutineScope(Dispatchers.IO).launch {
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.captureOneFrameNative(args["service_frame"] as Boolean)
                                result.success(true)
                            }
                        }
                        "update_configuration" -> {
                            CoroutineScope(Dispatchers.IO).launch {
                                val minArea = args["minArea"] as Int
                                val captureIntervalSec = args["captureIntervalSec"] as Int
                                val showAreaOnCapture = args["showAreaOnCapture"] as Boolean
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                captureRep?.updateConfiguration(minArea, captureIntervalSec, showAreaOnCapture)
                                result.success(true)
                            }
                        }
                        "get_cameras" -> {
                            CoroutineScope(Dispatchers.IO).launch {
                                val captureRep = (context.applicationContext as App?)?.captureRep
                                if (captureRep == null) {
                                    result.error("", "cannot open", "")
                                    return@launch
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
                                        map2["id"] = cameraDesc.id
                                        map["$cameraIndex"] = map2
                                    }
                                }
                                result.success(map)
                            }
                        }
                        "get_system_sounds" -> {
                            val map = mutableMapOf<String, Any>()
                            val manager = RingtoneManager(this)
                            manager.setType(RingtoneManager.TYPE_NOTIFICATION)
                            val cursor = manager.cursor
                            while (cursor.moveToNext()) {
                                val id = cursor.getString(RingtoneManager.ID_COLUMN_INDEX)
                                val uri = cursor.getString(RingtoneManager.URI_COLUMN_INDEX)
                                val name = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                                map["$uri/$id"] = mapOf("uri" to "$uri/$id", "name" to name)
                            }
                            result.success(map)
                        }
                        "play_system_sound" -> {
                            CoroutineScope(Dispatchers.IO).launch {
                                val toneId = args["id"] as String
                                try {
                                    val tone =
                                        RingtoneManager.getRingtone(context, Uri.parse(toneId))
                                    tone.play()
                                } catch (e: NoSuchElementException) {
                                    Log.e(TAG, "error", e)
                                }
                                result.success(true)
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
                    CoroutineScope(Dispatchers.Main).launch {
                        methodChannel.invokeMethod("onCapture", mapOf("path" to path))
                    }
                }
                override fun onMovement() {
                    CoroutineScope(Dispatchers.Main).launch {
                        methodChannel.invokeMethod("onMovement", null)
                    }
                }

                override fun onFirstFrameNotify() {
                    CoroutineScope(Dispatchers.Main).launch {
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
