package com.example.detector

import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.util.Size
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class MyRenderer(val genTexture: () ->Long,
                 val updateFrame: () -> Unit,
                 val onUpdateSize: (size: Size) -> Unit) : GLSurfaceView.Renderer {
    private var textureId = 0L
    private var program: Int = 0
    private var surfaceWidth = 0
    private var surfaceHeight = 0
    private var positionHandle: Int = 0
    private var texCoordHandle: Int = 0
    private var textureUniformHandle: Int = 0

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        textureId = genTexture()

        GLES20.glClearColor(0f, 0f, 0f, 1f)

        // Compile and link shaders
        val vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexShaderCode)
        val fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentShaderCode)
        program = GLES20.glCreateProgram().apply {
            GLES20.glAttachShader(this, vertexShader)
            GLES20.glAttachShader(this, fragmentShader)
            GLES20.glLinkProgram(this)
        }

        // Get handles for the attributes and uniforms
        positionHandle = GLES20.glGetAttribLocation(program, "vPosition")
        texCoordHandle = GLES20.glGetAttribLocation(program, "aTexCoord")
        textureUniformHandle = GLES20.glGetUniformLocation(program, "uTexture")
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, height)
        onUpdateSize(Size(width, height))
        surfaceWidth = width
        surfaceHeight = height
    }

    override fun onDrawFrame(gl: GL10?) {
        updateFrame()
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)

        GLES20.glUseProgram(program)

        // Enable the vertex attribute and bind the vertex data
        GLES20.glEnableVertexAttribArray(positionHandle)
        vertexBuffer.position(0)
        GLES20.glVertexAttribPointer(positionHandle, 2, GLES20.GL_FLOAT, false, 0, vertexBuffer)

        // Enable the texture attribute and bind the texture coordinates
        GLES20.glEnableVertexAttribArray(texCoordHandle)
        textureBuffer.position(0)
        GLES20.glVertexAttribPointer(texCoordHandle, 2, GLES20.GL_FLOAT, false, 0, textureBuffer)

        // Activate the texture
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId.toInt())

        // Set the sampler to use texture unit 0
        GLES20.glUniform1i(textureUniformHandle, 0)

        // Draw the textured rectangle
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        // Disable the vertex attribute arrays after rendering
        GLES20.glDisableVertexAttribArray(positionHandle)
        GLES20.glDisableVertexAttribArray(texCoordHandle)
    }

    private fun loadShader(type: Int, shaderCode: String): Int {
        val shader = GLES20.glCreateShader(type)
        GLES20.glShaderSource(shader, shaderCode)
        GLES20.glCompileShader(shader)
        return shader
    }

    fun getSurfaceSize(): Size {
        return Size(surfaceWidth, surfaceHeight)
    }

//    fun resizeToRatio(videoWidth: Int, videoHeight: Int, screenWidth: Int, screenHeight: Int) {
//        // Get the dimensions of the video
//        val videoProportion = videoWidth.toFloat() / videoHeight.toFloat()
//
//        // Get the width of the screen
//        val screenProportion = screenWidth.toFloat() / screenHeight.toFloat()
//
//        // Get the SurfaceView layout parameters
//        _binding?.surfaceView?.let { surfaceView ->
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

    // Vertex and Texture Coordinate Data
    private val vertexCoords = floatArrayOf(
        -1f,  1f,  // Top Left
        1f,  1f,  // Top Right
        -1f, -1f,  // Bottom Left
        1f, -1f   // Bottom Right
    )

    private val textureCoords = floatArrayOf(
        0f, 0f,   // Top Left
        1f, 0f,   // Top Right
        0f, 1f,   // Bottom Left
        1f, 1f    // Bottom Right
    )
    private val vertexBuffer: FloatBuffer = ByteBuffer.allocateDirect(vertexCoords.size * 4)
        .order(ByteOrder.nativeOrder())
        .asFloatBuffer()
        .put(vertexCoords).apply { position(0) }

    private val textureBuffer: FloatBuffer = ByteBuffer.allocateDirect(textureCoords.size * 4)
        .order(ByteOrder.nativeOrder())
        .asFloatBuffer()
        .put(textureCoords).apply { position(0) }

    val vertexShaderCode =
        """
    attribute vec4 vPosition;
    attribute vec2 aTexCoord;
    varying vec2 vTexCoord;

    void main() {
        gl_Position = vPosition;
        vTexCoord = aTexCoord;
    }
    """.trimIndent()

    val fragmentShaderCode =
        """
    precision mediump float;
    varying vec2 vTexCoord;
    uniform sampler2D uTexture;

    void main() {
        gl_FragColor = texture2D(uTexture, vTexCoord);
    }
    """.trimIndent()
}