package com.who.zone

import android.app.Application
import android.util.Log

class App : Application() {
    lateinit var captureRep: CaptureRep

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "onCreate: $this")

        captureRep = CaptureRep(
            this,
            getExternalFilesDir(null)?.path ?: ""
        )
    }

    companion object {
        private const val TAG = "App"
        init {
            try {
                System.loadLibrary("opencv_java4")
                System.loadLibrary("opencv_cpp")
            } catch (e: Exception) {
                Log.e(TAG, e.toString())
            }
        }
    }
}