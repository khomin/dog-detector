package com.example.detector

import android.content.Context
import android.opengl.GLSurfaceView
import android.util.Log
import android.util.Size
import android.view.View
import android.view.ViewGroup
//import androidx.constraintlayout.widget.ConstraintLayout
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class CaptureRep(val context: Context) {
    var cameraTool: CameraTool = CameraTool(context)

    private var surfaceView: GLSurfaceView ?= null
//    var layout: ConstraintLayout ?= null

    var cameraDescription: CameraDescription ?= null
    var cameraSize: Size = Size(0,0)
    var render: MyRenderer?= null
    var isRunning = false
    val tag = "CaptureRep"

    fun initRender(surfaceView: GLSurfaceView) {
        this.surfaceView = surfaceView
        render = MyRenderer(genTexture = {
            cameraTool.genTextureNative()
        }, updateFrame = {
            cameraTool.updateFrameNative()
        }, onUpdateSize = { surfaceSize ->
            cameraTool.updateViewSizeNative(
                surfaceSize.width, surfaceSize.height,
                cameraTool.sensorOrientation,
                cameraTool.deviceOrientation,
                cameraTool.cameraFacing.ordinal
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

    fun start(cameraId: String): Size {
        stop()
        val desc = cameraTool.getDescription(cameraId, context)
        if(desc == null) {
            Log.e(tag, "camera info is null")
            return Size(0, 0)
        }
        isRunning = true
        cameraDescription = desc
        cameraSize = desc.size.lastOrNull() ?: return Size(0, 0)
        cameraTool.openCamera(cameraId, cameraSize.width, cameraSize.height, desc.facing,  context)
        return Size(cameraSize.width, cameraSize.height)
    }

    fun stop() {
        cameraTool.closeCamera()
        isRunning = false
    }

//    fun updateViewSize() {
//        val surfaceSize = render?.getSurfaceSize() ?: return
//        cameraTool.updateViewSizeNative(
//            surfaceSize.width, surfaceSize.height,
//            cameraTool.sensorOrientation,
//            cameraTool.deviceOrientation,
//            cameraTool.cameraFacing.ordinal
//        )
//        // adjust layout
//        val surfaceView = surfaceView ?: return
//        val layout = layout ?: return
//        val frameWidth = cameraSize.width
//        val frameHeight = cameraSize.height
//        val screenWidth = layout.width
//        val screenHeight =  layout.height
//        val sensorOrientation = cameraTool.sensorOrientation
//        val deviceOrientation = cameraTool.deviceOrientation
//        var totalRotation = (sensorOrientation + deviceOrientation) % 360;
//        totalRotation = (360 - totalRotation) % 360; // Mirror for front-facing
//        var videoWidth2 = frameWidth
//        var videoHeigh2 = frameHeight
//        when (totalRotation) {
//            0 -> {}
//            90 -> {
//                videoWidth2 = frameHeight
//                videoHeigh2 = frameWidth
//            }
//            180 -> {}
//            270 -> {
//                videoWidth2 = frameHeight
//                videoHeigh2 = frameWidth
//            }
//        }
//        // Get the dimensions of the video
//        val videoProportion = videoWidth2.toFloat() / videoHeigh2.toFloat()
//
//        // Get the width of the screen
//        val screenProportion = screenWidth.toFloat() / screenHeight.toFloat()
//
//        // Get the SurfaceView layout parameters
//        CoroutineScope(Dispatchers.Main).launch {
//            val lp: ViewGroup.LayoutParams = surfaceView.layoutParams
//            if (videoProportion > screenProportion) {
//                lp.width = screenWidth
//                lp.height = (screenWidth.toFloat() / videoProportion).toInt()
//            } else {
//                lp.width = (videoProportion * screenHeight.toFloat()).toInt()
//                lp.height = screenHeight
//            }
//            // Commit the layout parameters
//            surfaceView.setLayoutParams(lp)
//        }
//    }
}