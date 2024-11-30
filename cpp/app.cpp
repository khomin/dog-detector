#include "app.hpp"
#include <iostream>
#include <fstream>
#include <thread>

#include <opencv2/opencv.hpp>
#include <GLES2/gl2.h>
#include "libyuv/convert.h"
#include "libyuv/basic_types.h"
#include "libyuv/convert.h"
#include "libyuv/convert_argb.h"
#include "libyuv/convert_from.h"
#include "libyuv/convert_from_argb.h"
#include "libyuv/rotate.h"
#include <jni.h>

GLuint textureId = 0;
std::mutex lock;

//std::mutex lock;
cv::Mat outFrame;
cv::Mat inFrame;
std::atomic<bool> onClose = false;

std::condition_variable condVar;

int initOpencv() {
    auto th = std::thread([&] {
        while (!onClose) {

            std::unique_lock<std::mutex> lk(lock);
            condVar.wait(lk, [&]() { return !inFrame.empty(); });

            cv::Mat frame;
//            inFrame;

//            cv::Mat matRGBA;
//            if (frame.channels() == 3) {
//                cv::cvtColor(frame, matRGBA, cv::COLOR_BGR2BGRA);
//            } else if (frame.channels() == 1) {
//                cv::cvtColor(frame, matRGBA, cv::COLOR_BGR2RGBA);
//            }
            std::lock_guard<std::mutex> l(lock);
//            cv::resize(matRGBA, outFrame, cv::Size(), 0.2, 0.2);
//            outFrame = matRGBA;
        }
        return 0;
    });
    th.detach();
    return 0;
}

extern "C"
JNIEXPORT long JNICALL
Java_com_example_detector_CameraTools_genTexture(JNIEnv *env, jobject thiz) {
    // generate a texture ID
    glGenTextures(1, &textureId);
    // bind the texture
    glBindTexture(GL_TEXTURE_2D, textureId);
    // configure the texture parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    // unbind the texture (optional)
    glBindTexture(GL_TEXTURE_2D, 0);
    return textureId;
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CameraTools_openCameraNative(JNIEnv *env, jobject thiz,
                                                       jstring video_type, jint width, jint height,
                                                       jint frame_rate, jint rotate) {

}
extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CameraTools_closeCameraNative(JNIEnv *env, jobject thiz) {
    onClose = true;
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CameraTools_putFrameNative(JNIEnv *env, jobject thiz,
                                                     jbyteArray y_plane,
                                                     jint yStride,
                                                     jbyteArray u_plane,
                                                     jint uStride,
                                                     jbyteArray v_plane,
                                                     jint vStride,
                                                     jint uvPixelStride,
                                                     jint width, jint height) {
    jbyte *y_plane_byte = env->GetByteArrayElements(y_plane, nullptr);
    jbyte *u_plane_byte = env->GetByteArrayElements(u_plane, nullptr);
    jbyte *v_plane_byte = env->GetByteArrayElements(v_plane, nullptr);

    auto dst_argb_size = width * height * 4;
    auto dst_argb = std::shared_ptr<uint8_t>(new uint8_t[dst_argb_size]);
    libyuv::Android420ToABGR((uint8_t *) y_plane_byte,
                         yStride,
                         (uint8_t *) u_plane_byte,
                         uStride,
                         (uint8_t *) v_plane_byte,
                         vStride,
                         uvPixelStride,
                         dst_argb.get(),
                         width * 4,
                         width, height);
    {
//        std::lock_guard<std::mutex> l(lock);
//        inFrame = cv::Mat(height, width, CV_8UC4, dst_argb.get());
//        outFrame = cv::Mat(height, width, CV_8UC4, dst_argb.get());
    }
//    device->putVideoFrame((uint8_t *) dst_argb.get(), dst_argb_size, width, height);

//    std::lock_guard<std::mutex> lk(lock);
//    ++count_;
//    cv_.notify_one();

    env->ReleaseByteArrayElements(y_plane, y_plane_byte, 0);
    env->ReleaseByteArrayElements(u_plane, u_plane_byte, 0);
    env->ReleaseByteArrayElements(v_plane, v_plane_byte, 0);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CameraTools_updateFrame(JNIEnv *env, jobject thiz) {
    std::lock_guard<std::mutex> l(lock);
    if(outFrame.empty()) {
        return;
    }
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, outFrame.cols, outFrame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, outFrame.data);
    glBindTexture(GL_TEXTURE_2D, 0);
}

//extern "C"
//JNIEXPORT jint JNICALL
//Java_com_example_detector_ui_home_HomeFragmentKt_initOpencv(JNIEnv *env, jclass clazz) {
//    return initOpencv();
//}

//extern "C"
//JNIEXPORT void JNICALL
//Java_com_example_detector_ui_home_HomeFragmentKt_startCapture(JNIEnv *env, jclass clazz) {
//    startCapture();
//}



//int startCapture() {
//    // Open video file
//    // cv::VideoCapture cap("video.mp4");
////    cv::VideoCapture cap(1);
////    if (!cap.isOpened()) {
////        std::cerr << "Error opening video file!" << std::endl;
////        return -1;
////    }
////return 0;
////    std::this_thread::sleep_for(std::chrono::microseconds(3000));
////    while (true) {
//
//        // 3. Create a blue rectangle as a texture
//        // Create a Mat filled with blue color
//        cv::Mat frame(400, 400, CV_8UC4, cv::Scalar(50, 50, 50, 100)); // Blue color (BGR format), which is filled as 255 in Blue channel
//
//        glBindTexture(GL_TEXTURE_2D, textureId);
//
//        // Upload the texture data to OpenGL
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame.data);
//
//        // Unbind the texture (optional)
//        glBindTexture(GL_TEXTURE_2D, 0);
//
////
//////        cv::Mat frame;
//////        if (!cap.read(frame)) break; // Exit if no frame is captured
////        // Convert to grayscale
//////        cv::Mat gray;
//////        auto channels= gray.channels();
////        // Show the result
////        // 2. Bind the texture
////        glBindTexture(GL_TEXTURE_2D, textureId);
////        // 3. Set texture parameters
////        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
////        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
////        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
////        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
////        // using dummy frame for now
//////        frame = cv::Mat(500, 500, CV_8UC1, cv::Scalar(200,200,200));
////        //
//////        cv::cvtColor(frame, frame, cv::COLOR_GRAY2RGBA);
////        // Upload cv::Mat to OpenGL texture
//////        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame.data);
////
////        auto frame = cv::Mat(400, 400, CV_8UC4, cv::Scalar(255, 50, 50, 255)); // Solid red
//////        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame.data);
////
////        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame.data);
////        // 6. Unbind the texture (optional, good practice)
////        glBindTexture(GL_TEXTURE_2D, 0);
//
////        std::this_thread::sleep_for(std::chrono::microseconds(10));
////    }
////    cap.release();
//    return 0;
//}
//
//
//int startCapture() {
//    // Open video file
//    // cv::VideoCapture cap("video.mp4");
//    cv::VideoCapture cap(1);
//    if (!cap.isOpened()) {
//        std::cerr << "Error opening video file!" << std::endl;
//        return -1;
//    }
//
//    // Background subtractor
//    cv::Ptr<cv::BackgroundSubtractor> bgSubtractor = cv::createBackgroundSubtractorMOG2(500, 50, true);
//
//    // Define ROI (x, y, width, height)
//    cv::Rect roi(0, 100, 300, 300);
//
//    while (true) {
//        cv::Mat frame;
//        if (!cap.read(frame)) break; // Exit if no frame is captured
//
//        // Convert to grayscale
//        cv::Mat gray;
//
//        auto channels= gray.channels();
//
//        std::cout << "Channels: " << channels << std::endl;
//
//        cv::cvtColor(frame, gray, cv::COLOR_GRAY2RGB);
//
//        // Apply the ROI
//        cv::Mat roiFrame = gray(roi);
//
//        // Background subtraction
//        cv::Mat fgMask;
//        bgSubtractor->apply(roiFrame, fgMask);
//
//        // Remove noise
//        cv::threshold(fgMask, fgMask, 25, 255, cv::THRESH_BINARY);
//        cv::morphologyEx(fgMask, fgMask, cv::MORPH_OPEN, cv::Mat());
//
//        // Find contours
//        std::vector<std::vector<cv::Point>> contours;
//        cv::findContours(fgMask, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
//
//        bool movementDetected = false;
//
//        for (const auto& contour : contours) {
//            // Filter by area
//            double area = cv::contourArea(contour);
//            if (area > 2000) {
//                movementDetected = true;
//
//                // Draw bounding box (adjust coordinates for the full frame)
//                cv::Rect boundingBox = cv::boundingRect(contour);
//                cv::rectangle(frame,
//                              cv::Point(roi.x + boundingBox.x, roi.y + boundingBox.y),
//                              cv::Point(roi.x + boundingBox.x + boundingBox.width, roi.y + boundingBox.y + boundingBox.height),
//                              cv::Scalar(0, 255, 0), 2);
//            }
//        }
//
//        // Draw ROI boundary
//        cv::rectangle(frame, roi, cv::Scalar(255, 0, 0), 2);
//
//        // Print movement status
//        if (movementDetected) {
//            std::cout << "Movement detected in ROI!" << std::endl;
//        } else {
//            std::cout << "No movement in ROI." << std::endl;
//        }
//
//        // Show the result
////        // 2. Bind the texture
//        glBindTexture(GL_TEXTURE_2D, textureId);
//        // 3. Set texture parameters
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//
//        // 4. Convert cv::Mat to RGBA if needed (OpenGL needs the data in the correct format)
////        cv::Mat matRGBA;
////        if (frame.channels() == 3) {
////            cv::cvtColor(frame, matRGBA, cv::COLOR_BGR2RGBA);
////        } else if (frame.channels() == 1) {
////            cv::cvtColor(frame, matRGBA, cv::COLOR_GRAY2RGBA);
////        } else {
////            matRGBA = frame;
////        }
//        frame = cv::Mat(frame.rows, frame.cols, frame.type(), cv::Scalar(255,0,255));
////        matRGBA = cv::Mat(frame.rows, frame.cols, frame.type(), cv::Scalar(255,0,255));
//
//        // Upload cv::Mat to OpenGL texture
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame.data);
////        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, matRGBA.cols, matRGBA.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, matRGBA.data);
//        // 6. Unbind the texture (optional, good practice)
//        glBindTexture(GL_TEXTURE_2D, 0);
//    }
//    cap.release();
//    return 0;
//}

//    auto thFile = std::thread([&] {
//        std::this_thread::sleep_for(std::chrono::seconds (1));
//        cv::Mat mat;
//        {
//            std::lock_guard<std::mutex> l(lock);
//            if (outFrame.empty()) {
//                return 0;
//            }
//            mat = outFrame;
//        }
//        std::vector<uchar> buf;
//        std::vector<int> param(2);
//        param[0] = cv::IMWRITE_JPEG_QUALITY;
//        param[1] = 80;//default(95) 0-100
//        cv::imencode(".jpg", mat, buf, param);
//        auto out = std::ofstream("/sdcard/DCIM/my_test.jpg");
//        out.write((char*) buf.data(), buf.size());
//        return 0;
//    });
//    thFile.detach();