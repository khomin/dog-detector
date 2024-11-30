cmake_minimum_required(VERSION 3.5)

set(PROJECT opencv_cpp)

project(${PROJECT} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(../cpp/libyuv)

if (ANDROID OR __ANDROID__)
  set(ARCH_NAME ${CMAKE_ANDROID_ARCH_ABI})
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-Bsymbolic")
  if (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "armeabi-v7a")
    set(ARCH_NAME "armv7")
  elseif (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "arm64-v8a")
    set(ARCH_NAME "arm64")
  elseif (${CMAKE_ANDROID_ARCH_ABI} STREQUAL "x86_64")
    set(ARCH_NAME "x86_64")
  elseif(${CMAKE_ANDROID_ARCH_ABI})
    error("unknown architecture ${CMAKE_SYSTEM_PROCESSOR}")
  endif ()
  set(SOURCES ${SOURCES}
    main.cpp
  )
  set(INCLUDE_DIRS ${INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/../lib_pack/opencv/${ARCH_NAME}/sdk/native/jni/include
    ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/
    ../cpp/libyuv/include
  )
  set(LIBRARIES ${LIBRARIES}
    ${CMAKE_CURRENT_SOURCE_DIR}/../lib_pack/opencv/${ARCH_NAME}/sdk/native/libs/${CMAKE_ANDROID_ARCH_ABI}/libopencv_java4.so
    GLESv2
    yuv
  )
endif()

add_library(${PROJECT} SHARED
  app.cpp
  app.hpp
)

target_include_directories(${PROJECT} PUBLIC
  ${INCLUDE_DIRS}
)

target_link_libraries(${PROJECT} PUBLIC
    ${LIBRARIES}
)

message("BTEST_INCLUDES: ${INCLUDE_DIRS}")
message("BTEST_LIBRARIES: ${LIBRARIES}")
