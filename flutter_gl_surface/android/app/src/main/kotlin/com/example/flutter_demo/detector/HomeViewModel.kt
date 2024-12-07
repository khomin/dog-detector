package com.example.flutter_demo.detector

import android.util.Size
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.example.detector.CameraInfo
import com.example.detector.CameraTools
import com.example.detector.MyRenderer

class HomeViewModel : ViewModel() {
    var cameraTools: CameraTools?= null
    var cameraInfo: CameraInfo ?= null
    var cameraSize: Size = Size(0,0)
    var render: MyRenderer?= null
    var cameraSizeList: MutableList<Size> = mutableListOf()

    private val _text = MutableLiveData<String>().apply {
        value = "This is home Fragment"
    }
    val text: LiveData<String> = _text
}