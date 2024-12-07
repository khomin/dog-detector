package com.example.flutter_demo.detector

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.example.detector.CameraFacing
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
            if(_model.cameraTools == null) {
                activity?.windowManager?.let { windowManager ->
                    _model.cameraTools = CameraTools(context, windowManager)
                }
            }
            _model.text.observe(viewLifecycleOwner) {
                binding.textHome.text = it
            }
            _binding?.buttonInit?.setOnClickListener {
                val info = _model.cameraTools?.getCameraInfo("0", context)
                if(info != null) {
                    _model.cameraSizeList.addAll(info.size)
                }
            }
            _binding?.buttonStart0?.setOnClickListener {
                val cameraTools = _model.cameraTools ?:return@setOnClickListener
                stop()
                val info = cameraTools.getCameraInfo("0", context)
                start("0", info.facing)
            }
            _binding?.buttonStart1?.setOnClickListener {
                val cameraTools = _model.cameraTools ?:return@setOnClickListener
                stop()
                val info = cameraTools.getCameraInfo("1", context)
                start("1", info.facing)            }
            _binding?.buttonStop?.setOnClickListener {
                stop()
            }
            if(_model.render != null) {
                _binding?.surfaceView?.visibility = View.VISIBLE
                _binding?.surfaceView?.setEGLContextClientVersion(2)
                _binding?.surfaceView?.setRenderer(_model.render)
            }
            updateViewSize()
        }
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding?.surfaceView?.onPause()
        _binding = null
    }

    private fun resizeToRatio(videoWidth: Int, videoHeight: Int) {
        val screenWidth = _binding?.layoutHome?.width
        val screenHeight =  _binding?.layoutHome?.height
        if(screenWidth == null || screenHeight == null) return
        val camera = _model.cameraTools ?: return
        val sensorOrientation = camera.getOrientation()
        val deviceOrientation = camera.getDeviceOrientation()
//        int totalRotation = (sensorOrientation - deviceOrientation + 360) % 360;
        var totalRotation = (sensorOrientation + deviceOrientation) % 360;
        totalRotation = (360 - totalRotation) % 360; // Mirror for front-facing

        var videoWidth2 = videoWidth
        var videoHeigh2 = videoHeight

//        val screenWidth = layoutSize.

        when (totalRotation) {
            0 -> {}
            90 -> {
                videoWidth2 = videoHeight
                videoHeigh2 = videoWidth
            }
            180 -> {}
            270 -> {
                videoWidth2 = videoHeight
                videoHeigh2 = videoWidth
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

    private fun start(id: String, facing: CameraFacing) {
        val contextSafe = context ?: return
        val camera = _model.cameraTools ?: return
        val info = camera.getCameraInfo(id, contextSafe)
        _model.cameraInfo = info
        _model.cameraSize = info.size.lastOrNull() ?: return
        if (_model.render == null) {
            initRender(camera)
        }
        camera.openCamera(id, _model.cameraSize.width, _model.cameraSize.height, facing,  contextSafe)
    }

    private fun stop() {
        _model.cameraTools?.closeCamera()
    }

    private fun initRender(camera: CameraTools) {
        _binding?.surfaceView?.visibility = View.VISIBLE
        _binding?.surfaceView?.setEGLContextClientVersion(2)
        _model.render = MyRenderer(genTexture = {
            camera.genTextureNative()
        }, updateFrame = {
            camera.updateFrameNative()
        }, onUpdateSize = { surfaceSize ->
            camera.updateViewSizeNative(
                surfaceSize.width, surfaceSize.height,
                camera.getOrientation(),
                camera.getDeviceOrientation(),
                camera.cameraFacing.ordinal
            )
        })
        _binding?.surfaceView?.setRenderer(_model.render)
    }

    private fun updateViewSize() {
        // update size after view rebuilt
        val surfaceSize = _model.render?.getSurfaceSize() ?: return
        val camera = _model.cameraTools ?: return
        camera.updateViewSizeNative(
            surfaceSize.width, surfaceSize.height,
            camera.getOrientation(),
            camera.getDeviceOrientation(),
            camera.cameraFacing.ordinal
        )
        CoroutineScope(Dispatchers.Main).launch {
            resizeToRatio(
                _model.cameraSize.width,
                _model.cameraSize.height
            )
        }
    }
}