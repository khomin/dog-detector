package com.example.detector

import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import android.Manifest
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (hasPermissions(this)) {
            // If permissions have already been granted, proceed
        } else {
            requestPermissions(PERMISSIONS_REQUIRED, PERMISSIONS_REQUEST_CODE)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val surfaceFactory = MyGLSurfaceViewFactory(flutterEngine.dartExecutor.binaryMessenger, null)

        val registry: PlatformViewRegistry = flutterEngine.platformViewsController.registry
        registry.registerViewFactory("my_gl_surface_view", surfaceFactory)

//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dev/cmd")
//            .setMethodCallHandler { call, result ->
//                try {
//                    val args = call.arguments as HashMap<*, *>
//                    when (call.method) {
//                        "start_camera" -> {
//                            val id = args["id"] as String
//                            val captureRep = (application as App?)?.captureRep
//                            result.success(true)
//                        }
//                        else -> {
//                            result.success(true)
//                        }
//                    }
//                } catch (e: Exception) {
//                    Log.e(TAG, "Error parsing", e)
//                }
//
//            }
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
