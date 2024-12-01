package com.example.detector.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.example.detector.CameraTools
import com.example.detector.MyRenderer
import com.example.detector.databinding.FragmentHomeBinding
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

class HomeFragment : Fragment() {
    private var _binding: FragmentHomeBinding? = null
    private lateinit var _model: HomeViewModel
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _model = ViewModelProvider(this)[HomeViewModel::class.java]
        _binding = FragmentHomeBinding.inflate(inflater, container, false)
        context?.let { context ->
            activity?.windowManager?.let { windowManager ->
                _model.cameraTools = CameraTools(context, windowManager)
            }
            _model.text.observe(viewLifecycleOwner) {
                binding.textHome.text = it
            }
            _binding?.buttonInit?.setOnClickListener {
                val size = _model.cameraTools?.getCameraSize("1", context)
                if(size != null) {
                    _model.cameraSizeList.addAll(size)
                }
            }
            _binding?.buttonStart0?.setOnClickListener {
                start("0")
            }
            _binding?.buttonStart1?.setOnClickListener {
                start("1")
            }
            _binding?.buttonStop?.setOnClickListener {
                stop()
            }
            // update size after view rebuilt
            val surfaceSize = _model.render?.getSurfaceSize()
            val camera = _model.cameraTools
            if (surfaceSize != null && camera != null) {
                _binding?.surfaceView?.visibility = View.VISIBLE
                _binding?.surfaceView?.setEGLContextClientVersion(2)
                _binding?.surfaceView?.setRenderer(_model.render)
                CoroutineScope(Dispatchers.Main).launch {
                    resizeToRatio(
                        _model.cameraSize.width,
                        _model.cameraSize.height,
                        surfaceSize.width,
                        surfaceSize.height
                    )
                }
                camera.updateViewSize(
                    surfaceSize.width, surfaceSize.height,
                    camera.getOrientation(),
                    camera.getDeviceOrientation()
                )
            }
        }
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    private fun resizeToRatio(videoWidth: Int, videoHeight: Int, screenWidth: Int, screenHeight: Int) {
        val camera = _model.cameraTools ?: return
        val sensorOrientation = camera.getOrientation()
        val deviceOrientation = camera.getDeviceOrientation()
//        int totalRotation = (sensorOrientation - deviceOrientation + 360) % 360;
        var totalRotation = (sensorOrientation + deviceOrientation) % 360;
        totalRotation = (360 - totalRotation) % 360; // Mirror for front-facing

        var videoWidth2 = videoWidth
        var videoHeigh2 = videoHeight

        when (totalRotation) {
            0 -> {
//                screenWidth2 = screenWidth
//                screenHeight2 = screenHeight
            }
            90 -> {
//                cv::rotate(frame, frame, cv::ROTATE_90_CLOCKWISE)
                videoWidth2 = videoHeight
                videoHeigh2 = videoWidth
            }
            180 -> {
//                cv::rotate(frame, frame, cv::ROTATE_180)
//                screenWidth2 = screenWidth
//                screenHeight2 = screenHeight
            }
            270 -> {
//                cv::rotate(frame, frame, cv::ROTATE_90_COUNTERCLOCKWISE)
//                var w = screenWidth
//                var h = screenHeight
//                screenWidth2 = h
//                screenHeight2 = w
            }
        }

        // Get the dimensions of the video
        val videoProportion = videoWidth2.toFloat() / videoHeigh2.toFloat()

        // Get the width of the screen
        val screenProportion = screenWidth.toFloat() / screenHeight.toFloat()

        // Get the SurfaceView layout parameters
        _binding?.surfaceView?.let { surfaceView ->
            val lp: ViewGroup.LayoutParams = surfaceView.layoutParams
            if (videoProportion > screenProportion) {
                lp.width = screenWidth
                lp.height = (screenWidth.toFloat() / videoProportion).toInt()
            } else {
                lp.width = (videoProportion * screenHeight.toFloat()).toInt()
                lp.height = screenHeight
            }
            // Commit the layout parameters
            surfaceView.setLayoutParams(lp)
        }
    }

    private fun start(id: String) {
        context?.let { context->
            val camera = _model.cameraTools ?: return
            val sizeList = camera.getCameraSize("1", context)
            _model.cameraSize = sizeList.lastOrNull() ?: return
            _binding?.surfaceView?.visibility = View.VISIBLE
            _binding?.surfaceView?.setEGLContextClientVersion(2)
            _model.render = MyRenderer(genTexture = {
                camera.genTexture()
            }, updateFrame = {
                camera.updateFrame()
            }, onUpdateSize = { surfaceSize ->
                CoroutineScope(Dispatchers.Main).launch {
                    resizeToRatio(
                        _model.cameraSize.width,
                        _model.cameraSize.height,
                        surfaceSize.width,
                        surfaceSize.height
                    )
                }
                camera.updateViewSize(
                    surfaceSize.width, surfaceSize.height,
                    camera.getOrientation(),
                    camera.getDeviceOrientation()

                )
            })
            _binding?.surfaceView?.setRenderer(_model.render)
            camera.openCamera(id, _model.cameraSize.width, _model.cameraSize.height, context)
        }
    }

    private fun stop() {
        _model.cameraTools?.closeCamera()
        _model.render = null
    }
}