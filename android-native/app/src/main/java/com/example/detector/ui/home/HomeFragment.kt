package com.example.detector.ui.home

import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.os.Bundle
import android.util.Log
import android.util.Size
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.example.detector.CameraTools
import com.example.detector.MyRenderer
import com.example.detector.databinding.FragmentHomeBinding

class HomeFragment : Fragment() {
    private var _binding: FragmentHomeBinding? = null
    private val binding get() = _binding!!
    private lateinit var cameraTools: CameraTools
//    private var cameraSize: HashMap<String, Size> = HashMap()
    private var cameraSize: MutableList<Size> = mutableListOf()

    // TODO:

    // 1
    // Button INIT
    // - getSize("0")
    // - getSize("1")
    // - show sizes in binding -> ComBox

    // 2
    // Button START
    // openCamera <= ComBox value (binding)
    // start opengl thread

    // 4
    // Button closeCamera
    // closeCamera
    // stop opengl thread

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val homeViewModel = ViewModelProvider(this)[HomeViewModel::class.java]
        _binding = FragmentHomeBinding.inflate(inflater, container, false)

        context?.let { context ->
            cameraTools = CameraTools(context)

            homeViewModel.text.observe(viewLifecycleOwner) {
                binding.textHome.text = it
            }
            _binding?.buttonInit?.setOnClickListener {
                val size = cameraTools.getCameraSize("1", context)
                cameraSize.addAll(size)
            }
            _binding?.buttonStart?.setOnClickListener {
                val sizeList = cameraTools.getCameraSize("1", context)
                val size = sizeList.lastOrNull() ?: return@setOnClickListener
                _binding?.surfaceView?.visibility = View.VISIBLE
                _binding?.surfaceView?.setEGLContextClientVersion(2)
                _binding?.surfaceView?.setRenderer(MyRenderer(genTexture = {
                    cameraTools.genTexture()
                }, updateFrame = {
                    cameraTools.updateFrame()
                }))
                cameraTools.openCamera("1", size.width, size.height, 30, context)
            }
            _binding?.buttonStop?.setOnClickListener {
                cameraTools.closeCamera()
            }
        }
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}