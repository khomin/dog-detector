package com.example.detector

import android.content.Context
import android.opengl.GLSurfaceView
import android.util.Log
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.runBlocking

class MyGLSurfaceViewFactory(
    private val messenger: BinaryMessenger, createArgsCodec: MessageCodec<Any>?
) : PlatformViewFactory(createArgsCodec) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return MyGLSurfacePlatformView(context, messenger, id)
    }
}

class MyGLSurfacePlatformView(
    val context: Context,
    messenger: BinaryMessenger,
    id: Int
) : PlatformView, MethodChannel.MethodCallHandler {
    private val glSurfaceView: GLSurfaceView = GLSurfaceView(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "camera/cmd")
    private val tag = "MyGLSurface"
    init {
        glSurfaceView.visibility = View.GONE
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return glSurfaceView
    }

    override fun onFlutterViewAttached(flutterView: View) {
        super.onFlutterViewAttached(flutterView)
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as HashMap<*, *>
        when (call.method) {
            "init_render" -> {
                val captureRep = (context.applicationContext as App?)?.captureRep
                captureRep?.initRender(glSurfaceView)
                result.success(true)
            }
            "start_camera" -> {
                val id = args["id"] as String
                val minArea = args["minArea"] as Int
                val captureIntervalSec = args["captureIntervalSec"] as Int
                val showAreaOnCapture = args["showAreaOnCapture"] as Boolean
                val captureRep = (context.applicationContext as App?)?.captureRep
                runBlocking {
                    val size = captureRep?.start(id, minArea, captureIntervalSec, showAreaOnCapture)
                    result.success(mapOf(
                        "size_width" to size?.width,
                        "size_height" to size?.height))
                }
            }
            "stop_camera" -> {
                val captureRep = (context.applicationContext as App?)?.captureRep
                runBlocking {
                    captureRep?.stop()
                    result.success(true)
                }
            }
            "update_configuration" -> {
                val minArea = args["minArea"] as Int
                val captureIntervalSec = args["captureIntervalSec"] as Int
                val showAreaOnCapture = args["showAreaOnCapture"] as Boolean
                val captureRep = (context.applicationContext as App?)?.captureRep
                runBlocking {
                    captureRep?.updateConfiguration(minArea, captureIntervalSec, showAreaOnCapture)
                    result.success(true)
                }
            }
            "get_cameras" -> {
                val captureRep = (context.applicationContext as App?)?.captureRep
                runBlocking {
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
            else -> result.notImplemented()
        }
    }
}