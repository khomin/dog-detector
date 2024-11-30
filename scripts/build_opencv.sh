
# build opencv Android

# how to use
# export NDK=/Users/user/Library/Android/sdk/ndk/26.1.10909125
# export NDK=~/Android/Sdk/ndk/26.1.10909125/

# export CMAKE_SYSROOT=${NDK}/toolchains/llvm/prebuilt/darwin-x86_64/sysroot/
# export TOOLCHAIN=${NDK}/build/cmake/android.toolchain.cmake
# export INSTALL_PATH_PREFIX=~/Documents/PROJECTS/dog-detector/lib_pack/opencv

if [ -z "$NDK" ]
then
    echo "NDK not defined"
    exit 0
fi

if [ -z "$CMAKE_SYSROOT" ]
then
    echo "CMAKE_SYSROOT not defined"
    exit 0
fi

if [ -z "$TOOLCHAIN" ]
then
    echo "TOOLCHAIN not defined"
    exit 0
fi

if [ -z "$INSTALL_PATH_PREFIX" ]
then
    echo "INSTALL_PATH_PREFIX not defined"
    exit 0
fi

echo "------------------"
echo "USING-NDK: ${NDK}"
echo "USING-CMAKE_SYSROOT: ${CMAKE_SYSROOT}"
echo "USING-TOOLCHAIN: ${TOOLCHAIN}"
echo "USING-INSTALL_PATH_PREFIX: ${INSTALL_PATH_PREFIX}"
echo "------------------"

# x86
mkdir x86
cd ./x86
cmake ../../ -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} \
-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
-Dprotobuf_BUILD_TESTS=OFF \
-DCMAKE_SYSTEM_NAME=Android \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_SYSTEM_PROCESSOR=x86 \
-DANDROID_ABI=x86 \
-DANDROID_NDK=${NDK} \
-DANDROID_PLATFORM=android-26 \
-DCMAKE_CXX_FLAGS="-llog" \
-Dprotobuf_BUILD_TESTS=OFF
make -j32
cmake --install . --prefix ${INSTALL_PATH_PREFIX}/x86
cd ../

# aarch64
mkdir aarch64
cd ./aarch64
cmake ../../ -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} \
-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
-DCMAKE_BUILD_TYPE=Release \
-Dprotobuf_BUILD_TESTS=OFF \
-DCMAKE_SYSTEM_NAME=Android \
-DCMAKE_SYSTEM_PROCESSOR=aarch64 \
-DANDROID_ABI=arm64-v8a \
-DANDROID_NDK=${NDK} \
-DANDROID_PLATFORM=android-26 \
-DCMAKE_ANDROID_ARCH_ABI=arm64-v8a  \
-DCMAKE_ANDROID_NDK=${NDK} \
-DCMAKE_CXX_FLAGS="-llog"
make -j32
cmake --install . --prefix ${INSTALL_PATH_PREFIX}/arm64
cd ../

# x86_64
mkdir x86_64
cd ./x86_64
cmake ../../ -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN} \
-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
-Dprotobuf_BUILD_TESTS=OFF \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_SYSTEM_NAME=Android \
-DCMAKE_SYSTEM_PROCESSOR=x86_64 \
-DANDROID_ABI=x86_64 \
-DANDROID_NDK=${NDK} \
-DANDROID_PLATFORM=android-26 \
-DCMAKE_ANDROID_ARCH_ABI=x86_64  \
-DCMAKE_ANDROID_NDK=${NDK} \
-DCMAKE_CXX_FLAGS="-llog"
make -j32
cmake --install . --prefix ${INSTALL_PATH_PREFIX}/x86_64

echo "------------------"
echo "COMPLETED"
echo "------------------"