cmake_minimum_required(VERSION 3.5)

set(PROJECT opencv_cpp)

project(${PROJECT} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384")

add_subdirectory(../cpp/libyuv)

if (ANDROID OR __ANDROID__)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-Bsymbolic")
  set(SOURCES ${SOURCES}
    main.cpp
  )
  set(INCLUDE_DIRS ${INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/../lib_pack/opencv/${ANDROID_ABI}/sdk/native/jni/include
    ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/
    ../cpp/libyuv/include
  )
  set(LIBRARIES ${LIBRARIES}
    ${CMAKE_CURRENT_SOURCE_DIR}/../lib_pack/opencv/${ANDROID_ABI}/sdk/native/libs/${CMAKE_ANDROID_ARCH_ABI}/libopencv_java4.so
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

if (ANDROID OR __ANDROID__)
  target_link_options(
      ${PROJECT} PRIVATE
      "-Wl,-z,max-page-size=16384"
  )
endif()

target_link_libraries(${PROJECT} PUBLIC
    ${LIBRARIES}
)

message("BTEST_INCLUDES: ${INCLUDE_DIRS}")
message("BTEST_LIBRARIES: ${LIBRARIES}")
