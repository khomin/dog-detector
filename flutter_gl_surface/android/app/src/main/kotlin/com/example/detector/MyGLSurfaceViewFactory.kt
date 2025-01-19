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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking

class MyGLSurfaceViewFactory(
    private val messenger: BinaryMessenger, createArgsCodec: MessageCodec<Any>?
) : PlatformViewFactory(createArgsCodec) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return MyGLSurfacePlatformView(context, messenger)
    }
}

class MyGLSurfacePlatformView(
    val context: Context,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {
    private val glSurfaceView: GLSurfaceView = GLSurfaceView(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "camera/cmd")
    init {
        glSurfaceView.visibility = View.GONE
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        return glSurfaceView
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init_render" -> {
                val captureRep = (context.applicationContext as App?)?.captureRep
                captureRep?.initRender(glSurfaceView)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }
}