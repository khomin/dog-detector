# 🐶 Dog Detector

## 📋 Prerequisites

### Android

You need to build opencv manually using cmake, example: (adjust YOUR_DIR)

        cmake ../ \
        -DBUILD_EXAMPLES=OFF \
        -DOPENCV_FORCE_3RDPARTY_BUILD=ON \
        -DBUILD_TESTS=OFF \
        -DOPENCV_ENABLE_NONFREE=ON \
        -DBUILD_PROTOBUF=OFF \
        -DBUILD_opencv_dnn=OFF \
        -DCMAKE_INSTALL_PREFIX=YOUR_DIR/lib_pack/opencv/

        make -j16
        make install

so it will look like: 

    ./lib_pack/opencv/x86_64/..
    ./lib_pack/opencv/arm64/..
    ./lib_pack/opencv/x86/..

The library is loaded in App.kt:

    companion object {
        private const val TAG = "App"
        init {
            try {
                System.loadLibrary("opencv_cpp")
            } catch (e: Exception) {
                Log.e(TAG, e.toString())
            }
        }
    }