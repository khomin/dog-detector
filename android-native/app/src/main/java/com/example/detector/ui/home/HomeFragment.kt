package com.example.detector.ui.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProvider
import com.example.detector.App
import com.example.detector.databinding.FragmentHomeBinding

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

        val layout = _binding?.layoutHome
        val surfaceView = _binding?.surfaceView
        val captureRep = (activity?.application as App?)?.captureRep

        if(layout != null && surfaceView != null) {
            captureRep?.initRender(surfaceView)
            captureRep?.layout = layout
            _binding?.buttonStart0?.setOnClickListener {
                captureRep?.start("0")
                captureRep?.updateViewSize()
            }
            _binding?.buttonStart1?.setOnClickListener {
                captureRep?.start("1")
                captureRep?.updateViewSize()
            }
            _binding?.buttonStop?.setOnClickListener {
                captureRep?.stop()
            }
            captureRep?.reinit()
        }
        // update sensor orientation
        activity?.windowManager?.getDefaultDisplay()?.rotation?.let {
            captureRep?.cameraTool?.updateDeviceOrientation(it)
        }

        // update layout size
        captureRep?.updateViewSize()
        return binding.root
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}