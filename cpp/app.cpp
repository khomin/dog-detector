#include "app.hpp"
#include <iostream>
#include <fstream>
#include <thread>
#include <chrono>
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
uint64 frameCount = 0;
int viewWidth = 0;
int viewHeight = 0;
int sensorOrientation = 0;
int deviceOrientation = 0;
std::string appLocalDir;
CameraFace cameraFacing = CameraFace::back;
int minArea = 0;
int captureIntervalSec = 0;
bool captureActive = false;
bool captureOneFrame = false;
bool captureOneFrameService = false;
bool showAreaOnCapture = true;
std::chrono::steady_clock::time_point lastCaptureTime;
std::chrono::steady_clock::time_point lastMoveReportTime;

static JavaVM *mJVM;
jweak onSourceMethodRef = nullptr;
jmethodID onCaptureMethodId = nullptr;
jmethodID onMovementMethodId = nullptr;
jmethodID onFirstFrameNotifyMethodId = nullptr;

std::condition_variable condVar;
std::mutex condLock;
std::atomic<bool> isRun = false;

void captureFrame(cv::Mat& frame, bool service);
void reportOfMovement();

JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    mJVM = vm;
    return JNI_VERSION_1_6;
}

bool shouldCaptureFrame() {
    auto now = std::chrono::steady_clock::now();
    auto dur = now - lastCaptureTime;
    auto f_secs = std::chrono::duration_cast<std::chrono::duration<float>>(dur);
    auto count = (int) f_secs.count();
    return count >= captureIntervalSec;
}

bool shouldReportMovement() {
    auto now = std::chrono::steady_clock::now();
    auto dur = now - lastMoveReportTime;
    auto f_secs = std::chrono::duration_cast<std::chrono::duration<float>>(dur);
    auto count = (int) f_secs.count();
    return count >= 1;
}

std::string getCurrentDateString() {
    // Get current time as a time_point
    auto now = std::chrono::system_clock::now();
    // Convert time_point to time_t
    std::time_t now_time_t = std::chrono::system_clock::to_time_t(now);
    // Convert time_t to tm struct
    std::tm now_tm;
#ifdef _WIN32
    localtime_s(&now_tm, &now_time_t);  // For Windows
#else
    localtime_r(&now_time_t, &now_tm);  // For Unix/Linux
#endif
    // Create a string stream to format the date
    std::ostringstream oss;
    oss << std::put_time(&now_tm, "%Y-%m-%d");  // Format: YYYY-MM-DD
    return oss.str();  // Get the formatted date as a std::string
}

std::string getCurrentTimeString() {
    // Get current time as a time_point
    auto now = std::chrono::system_clock::now();
    std::time_t now_time_t = std::chrono::system_clock::to_time_t(now);
    // Convert to tm structure for broken-down time
    std::tm now_tm = *std::localtime(&now_time_t);
    // Use std::ostringstream to format the string
    std::ostringstream oss;
    oss << std::put_time(&now_tm, "%Y-%m-%d %H-%M-") << std::setw(3) << std::setfill('0') << (now.time_since_epoch().count() % 1000);
    return oss.str();
}

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
Java_com_example_detector_CaptureRep_startNative(JNIEnv *env, jobject thiz, jint width, jint height, jint minArea_, jint captureIntervalSec_, jboolean showAreaOnCapture_, jstring appLocalDir_) {
    {
        std::lock_guard<std::mutex> l(lock);
        isRun = true;
        minArea = minArea_;
        captureIntervalSec = captureIntervalSec_;
        showAreaOnCapture = showAreaOnCapture_;
        frameCount = 0;
        jboolean isCopy;
        const char *convertedValue = (env)->GetStringUTFChars(appLocalDir_, &isCopy);
        if(isCopy) {
            appLocalDir = convertedValue;
            env->ReleaseStringUTFChars(appLocalDir_, convertedValue);
        }
        lastCaptureTime = std::chrono::steady_clock::now();
    }
    auto th = std::thread([&] {
        // Background subtractor
        cv::Ptr<cv::BackgroundSubtractor> bgSubtractor = cv::createBackgroundSubtractorMOG2(500, 50, true);

        // Define ROI (x, y, width, height)
//        cv::Rect roi(100, 300, 600, 600);
//        cv::Rect roi(50, 50, 300, 300);
//        cv::Rect roi(0, 0, width-100, height-100);

        while (isRun) {
            cv::Mat frame;
            {
                std::unique_lock<std::mutex> lk(condLock);
                condVar.wait(lk, [&]() { return !inFrame.empty() || !isRun; });
                frame = std::move(inFrame);
            }
            if(frame.empty() || !isRun) {
                continue;
            }
            // Convert to grayscale
            cv::Mat gray;
            cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);

            // Apply the ROI
//            cv::Mat roiFrame = gray(roi);

            // Background subtraction
            cv::Mat fgMask;
//            bgSubtractor->apply(roiFrame, fgMask);
            bgSubtractor->apply(gray, fgMask);

            // Remove noise
            cv::threshold(fgMask, fgMask, 25, 255, cv::THRESH_BINARY);
            cv::morphologyEx(fgMask, fgMask, cv::MORPH_OPEN, cv::Mat());

            // Find contours
            std::vector<std::vector<cv::Point>> contours;
            cv::findContours(fgMask, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

            bool movementDetected = false;

            for (const auto& contour : contours) {
                // Filter by area
                double area = cv::contourArea(contour);
                if (area > minArea) { //2000) {
                    movementDetected = true;

                    // Draw bounding box (adjust coordinates for the full frame)
                    cv::Rect boundingBox = cv::boundingRect(contour);
//                    cv::rectangle(frame,
//                                  cv::Point(roi.x + boundingBox.x, roi.y + boundingBox.y),
//                                  cv::Point(roi.x + boundingBox.x + boundingBox.width, roi.y + boundingBox.y + boundingBox.height),
//                                  cv::Scalar(0, 255, 0), 2);

                    if(showAreaOnCapture) {
                        cv::rectangle(frame,
                                      cv::Point(boundingBox.x, boundingBox.y),
                                      cv::Point(boundingBox.x + boundingBox.width,
                                                boundingBox.y + boundingBox.height),
                                      cv::Scalar(0, 255, 0), 2);
                    }
                }
            }

            // Draw ROI boundary
//            cv::rectangle(frame, roi, cv::Scalar(255, 0, 0), 2);

            auto capture = false;
            auto captureService = false;
            auto report = false;
            {
                std::lock_guard<std::mutex> l(lock);
                if (captureOneFrame || captureOneFrameService || (movementDetected && captureActive)) {
                    if(captureOneFrame || captureOneFrameService || shouldCaptureFrame()) {
                        if (captureOneFrame) {
                            capture = true;
                        } else if (captureOneFrameService) {
                            captureService = true;
                        }
                    }
                    if(captureOneFrameService) {
                        captureOneFrameService = false;
                    } else if(captureOneFrame) {
                        captureOneFrame = false;
                    }
                }
            }
            if(movementDetected && shouldReportMovement()) {
                report = true;
            }
            {
                if(capture) {
                    captureFrame(frame, false);
                } if(captureService) {
                    captureFrame(frame, true);
                }
                if(report) {
                    reportOfMovement();
                }
            }
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
    {
        std::lock_guard<std::mutex> l(lock);
        isRun = false;
        outFrame = cv::Mat();
    }
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
    auto argbFrame = cv::Mat(height, width, CV_8UC4);
    libyuv::Android420ToABGR((uint8_t *) y_plane_byte,
                         yStride,
                         (uint8_t *) u_plane_byte,
                         uStride,
                         (uint8_t *) v_plane_byte,
                         vStride,
                         uvPixelStride,
                         argbFrame.data,
                         width * 4,
                         width, height);
    {
        std::lock_guard<std::mutex> l(lock);
        inFrame = argbFrame;
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
        if (!isRun) {
            if(!outFrame.empty()) {
                outFrame.setTo(cv::Scalar(0, 0, 255));
                glBindTexture(GL_TEXTURE_2D, textureId);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, outFrame.cols, outFrame.rows, 0, GL_RGBA,
                             GL_UNSIGNED_BYTE, outFrame.data);
                glBindTexture(GL_TEXTURE_2D, 0);
            }
            return;
        }
        if(outFrame.empty()) {
            return;
        }
        frame = outFrame;
    }
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, frame.cols, frame.rows, 0, GL_RGBA, GL_UNSIGNED_BYTE, frame.data);
    glBindTexture(GL_TEXTURE_2D, 0);

    if(frameCount == 0) {
        if(onFirstFrameNotifyMethodId != nullptr) {
            auto not_jni_thread = (*mJVM).GetEnv((void **) &env, JNI_VERSION_1_6) == JNI_EDETACHED;
            if (not_jni_thread) mJVM->AttachCurrentThread(&env, nullptr);
            env->CallVoidMethod(onSourceMethodRef, onFirstFrameNotifyMethodId);
            if (not_jni_thread) mJVM->DetachCurrentThread();
        }
        lastCaptureTime = std::chrono::steady_clock::now();
    }
    frameCount++;
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

void captureFrame(cv::Mat& frame, bool service) {
    JNIEnv *env;
    if(onCaptureMethodId != nullptr) {
        auto not_jni_thread = (*mJVM).GetEnv((void **) &env, JNI_VERSION_1_6) == JNI_EDETACHED;
        if (not_jni_thread) mJVM->AttachCurrentThread(&env, nullptr);
        if(!service) {
            auto dateStr = getCurrentDateString();
            auto fileName = getCurrentTimeString() + ".jpeg";
            auto path = appLocalDir + "/gallery/" + dateStr + "/" + fileName;
            // Get the parent directory of the file path
            std::filesystem::path dir = std::filesystem::path(path).parent_path();
            // Create the directory if it does not exist
            if (!std::filesystem::exists(dir)) {
                std::filesystem::create_directories(dir);
            }
            cv::Mat rgbFrame;
            cv::cvtColor(frame, rgbFrame, cv::COLOR_BGR2RGB);
            auto res = cv::imwrite(path, rgbFrame);
            jstring obj_msg_j = env->NewStringUTF(res ? path.c_str() : "");
            env->CallVoidMethod(onSourceMethodRef, onCaptureMethodId, obj_msg_j);
            env->DeleteLocalRef(obj_msg_j);
        } else {
            auto path = appLocalDir + "/service/service.jpeg";
            // Get the parent directory of the file path
            std::filesystem::path dir = std::filesystem::path(path).parent_path();
            // Create the directory if it does not exist
            if (!std::filesystem::exists(dir)) {
                std::filesystem::create_directories(dir);
            }
            cv::Mat rgbFrame;
            cv::cvtColor(frame, rgbFrame, cv::COLOR_BGR2RGB);
            auto res = cv::imwrite(path, rgbFrame);
            jstring obj_msg_j = env->NewStringUTF(res ? path.c_str() : "");
            env->CallVoidMethod(onSourceMethodRef, onCaptureMethodId, obj_msg_j);
            env->DeleteLocalRef(obj_msg_j);
        }

        if (not_jni_thread) mJVM->DetachCurrentThread();
    }
    lastCaptureTime = std::chrono::steady_clock::now();
}

void reportOfMovement() {
    JNIEnv *env;
    if(onMovementMethodId != nullptr) {
        auto not_jni_thread = (*mJVM).GetEnv((void **) &env, JNI_VERSION_1_6) == JNI_EDETACHED;
        if (not_jni_thread) mJVM->AttachCurrentThread(&env, nullptr);
        env->CallVoidMethod(onSourceMethodRef, onMovementMethodId);
        if (not_jni_thread) mJVM->DetachCurrentThread();
    }
    lastMoveReportTime = std::chrono::steady_clock::now();
}

extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_setListenerNative(JNIEnv *env, jobject thiz, jobject listener) {
    onSourceMethodRef = env->NewGlobalRef(listener);
    jclass callbackClass = env->GetObjectClass(onSourceMethodRef);
    onCaptureMethodId = env->GetMethodID(callbackClass, "onCapture", "(Ljava/lang/String;)V");
    onMovementMethodId = env->GetMethodID(callbackClass, "onMovement", "()V");
    onFirstFrameNotifyMethodId = env->GetMethodID(callbackClass, "onFirstFrameNotify", "()V");
}
extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_updateConfigurationNative(JNIEnv *env, jobject thiz, jint minArea_,
                                                         jint captureIntervalSec_,
                                                         jboolean showAreaOnCapture_) {
    {
        std::lock_guard<std::mutex> l(lock);
        minArea = minArea_;
        captureIntervalSec = captureIntervalSec_;
        showAreaOnCapture = showAreaOnCapture_;
    }
}
extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_setCaptureActiveNative(JNIEnv *env, jobject thiz, jboolean active) {
    std::lock_guard<std::mutex> l(lock);
    captureActive = active;
}
extern "C"
JNIEXPORT void JNICALL
Java_com_example_detector_CaptureRep_captureOneFrameNative(JNIEnv *env, jobject thiz, jboolean service) {
    std::lock_guard<std::mutex> l(lock);
    if(service) {
        captureOneFrameService = true;
    } else {
        captureOneFrame = true;
    }
}