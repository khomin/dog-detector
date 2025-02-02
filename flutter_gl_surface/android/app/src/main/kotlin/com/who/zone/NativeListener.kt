package com.who.zone

interface NativeListener {
    fun onCapture(path: String)
    fun onMovement()
    fun onFirstFrameNotify()
}
