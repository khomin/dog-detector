package com.example.detector

interface NativeListener {
    fun onCapture(path: String)
    fun onMovement()
}
