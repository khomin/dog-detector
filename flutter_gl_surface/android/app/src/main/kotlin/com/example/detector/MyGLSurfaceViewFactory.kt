package com.example.detector

import android.content.Context
import android.opengl.GLSurfaceView
import android.view.View
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import java.util.Objects

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
    private val methodChannel: MethodChannel = MethodChannel(messenger, "dev/cmd")
        //"my_gl_surface_view_$id")

    init {
        glSurfaceView.visibility = View.GONE
        // Set the MethodCallHandler to handle calls from Flutter
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return glSurfaceView
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments as HashMap<*, *>
        when (call.method) {
            "start_camera" -> {
                val id = args["id"] as String
                val captureRep = (context.applicationContext as App?)?.captureRep
                if(captureRep == null) {
                    result.error("", "cannot open", "")
                    return
                }
                captureRep.initRender(glSurfaceView)
                val size = captureRep.start(id)
                result.success(mapOf(
                    "size_width" to size.width,
                    "size_height" to size.height))
            }
            "stop_camera" -> {
                val captureRep = (context.applicationContext as App?)?.captureRep
                captureRep?.stop()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}

//                captureRep?.updateViewSize()
