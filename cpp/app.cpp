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

enum class CameraFace { front, back };

GLuint textureId = 0;
std::mutex lock;

cv::Mat outFrame;
cv::Mat inFrame;
int viewWidth = 0;
int viewHeight = 0;
int sensorOrientation = 0;
int deviceOrientation= 0;
CameraFace cameraFacing = CameraFace::back;

std::condition_variable condVar;
std::mutex condLock;
std::atomic<bool> isRun = false;

cv::Mat resizeWithAspectRatio(const cv::Mat& frame, int width, int height);

extern "C"
JNIEXPORT long JNICALL
Java_com_example_detector_CaptureRep_genTextureNative(JNIEnv *env, jobject thiz) {
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
Java_com_example_detector_CaptureRep_startNative(JNIEnv *env, jobject thiz, jint width, jint height) {
    isRun = true;
    auto th = std::thread([&] {
        // Background subtractor
        cv::Ptr<cv::BackgroundSubtractor> bgSubtractor = cv::createBackgroundSubtractorMOG2(500, 50, true);

        // Define ROI (x, y, width, height)
//        cv::Rect roi(100, 300, 600, 600);
//        cv::Rect roi(50, 50, 300, 300);
        cv::Rect roi(0, 0, 400, 100);

        while (isRun) {
            cv::Mat frame;
            {
                std::unique_lock<std::mutex> lk(condLock);
                condVar.wait(lk, [&]() { return !inFrame.empty(); });
                frame = inFrame.clone();
                inFrame.release();
            }
//            int totalRotation = 0;
//            if(cameraFacing == CameraFace::back) {
//                totalRotation = (sensorOrientation - deviceOrientation + 360) % 360;
//            } else if(cameraFacing == CameraFace::front) {
//                totalRotation = (sensorOrientation + deviceOrientation) % 360;
//            }
//            switch (totalRotation) {
//                case 0: break;
//                case 90:
//                    cv::rotate(frame, frame, cv::ROTATE_90_CLOCKWISE);
//                    break;
//                case 180:
//                    cv::rotate(frame, frame, cv::ROTATE_180);
//                    break;
//                case 270:
//                    cv::rotate(frame, frame, cv::ROTATE_90_COUNTERCLOCKWISE);
//                    break;
//                default:
//                    break;
//            }

//            frame = resizeWithAspectRatio(frame, viewWidth, viewHeight);
//            cv::resize(frame, frame, cv::Size(frame.cols/10, frame.rows/10));

//            float frameAspectRatio = static_cast<float>(frame.cols) / static_cast<float>(frame.rows);
//            float viewAspectRatio = static_cast<float>(width) / static_cast<float>(height);

//            cv::resize(frame, frame, cv::Size(0, 0), frameAspectRatio, viewAspectRatio);

//            // Convert to grayscale
//            cv::Mat gray;
//            cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);
//
//            // Apply the ROI
//            cv::Mat roiFrame = gray(roi);
//
//            // Background subtraction
//            cv::Mat fgMask;
//            bgSubtractor->apply(roiFrame, fgMask);
//
//            // Remove noise
//            cv::threshold(fgMask, fgMask, 25, 255, cv::THRESH_BINARY);
//            cv::morphologyEx(fgMask, fgMask, cv::MORPH_OPEN, cv::Mat());
//
//            // Find contours
//            std::vector<std::vector<cv::Point>> contours;
//            cv::findContours(fgMask, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
//
//            bool movementDetected = false;
//
//            for (const auto& contour : contours) {
//                // Filter by area
//                double area = cv::contourArea(contour);
//                if (area > 2000) {
//                    movementDetected = true;
//
//                    // Draw bounding box (adjust coordinates for the full frame)
//                    cv::Rect boundingBox = cv::boundingRect(contour);
//                    cv::rectangle(frame,
//                                  cv::Point(roi.x + boundingBox.x, roi.y + boundingBox.y),
//                                  cv::Point(roi.x + boundingBox.x + boundingBox.width, roi.y + boundingBox.y + boundingBox.height),
//                                  cv::Scalar(0, 255, 0), 2);
//                }
//            }
//
//            // Draw ROI boundary
//            cv::rectangle(frame, roi, cv::Scalar(255, 0, 0), 2);
//
//            // Print movement status
//            if (movementDetected) {
//                std::cout << "Movement detected in ROI!" << std::endl;
//            } else {
//                std::cout << "No movement in ROI." << std::endl;
//            }
            {
                std::lock_guard<std::mutex> l(lock);
                outFrame = frame;
            }
        }
        return 0;
    });
    th.detach();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_stopNative(JNIEnv *env, jobject thiz) {
    isRun = false;
    condVar.notify_one();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_putFrameNative(JNIEnv *env, jobject thiz,
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
        std::lock_guard<std::mutex> l(lock);
        inFrame = cv::Mat(height, width, CV_8UC4, dst_argb.get());
        condVar.notify_one();
    }
    env->ReleaseByteArrayElements(y_plane, y_plane_byte, 0);
    env->ReleaseByteArrayElements(u_plane, u_plane_byte, 0);
    env->ReleaseByteArrayElements(v_plane, v_plane_byte, 0);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_updateFrameNative(JNIEnv *env, jobject thiz) {
    cv::Mat frame;
    {
        std::lock_guard<std::mutex> l(lock);
        if (outFrame.empty()) {
            return;
        }
        frame = outFrame;
    }
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame.data);
    glBindTexture(GL_TEXTURE_2D, 0);
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_updateViewSizeNative(JNIEnv *env, jobject thiz, jint width,
                                                          jint height, jint sensorOrientation_, jint deviceOrientation_, jint facing) {
    std::lock_guard<std::mutex> l(lock);
    viewWidth = width;
    viewHeight = height;
    sensorOrientation = sensorOrientation_;
    deviceOrientation = deviceOrientation_;
    cameraFacing = (CameraFace) facing;
}

cv::Mat resizeWithAspectRatio(const cv::Mat& frame, int width, int height) {
    // Get current frame dimensions
    int frameWidth = frame.cols;
    int frameHeight = frame.rows;

    // Calculate the aspect ratios
    float frameAspectRatio = static_cast<float>(frameWidth) / static_cast<float>(frameHeight);
    float viewAspectRatio = static_cast<float>(viewWidth) / static_cast<float>(viewHeight);

    // Variables to hold the new dimensions
    int newWidth, newHeight;

    // Determine new dimensions to maintain aspect ratio
    if (frameAspectRatio > viewAspectRatio) {
        // Frame is wider than the view, constrain width
        newWidth = viewWidth;
        newHeight = static_cast<int>(viewWidth / frameAspectRatio);
    } else {
        // Frame is taller than or equal to the view, constrain height
        newHeight = viewHeight;
        newWidth = static_cast<int>(viewHeight * frameAspectRatio);
    }

    // Resize the frame
    cv::Mat resizedFrame;
    cv::resize(frame, resizedFrame, cv::Size(newWidth, newHeight));

    return resizedFrame;
}
