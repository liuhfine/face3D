//
// Created by sunny on 2018/2/3.
//

#ifndef PANORAMA_ANDROID_MLOG_H
#define PANORAMA_ANDROID_MLOG_H

#include <android/log.h>


#define  LOG_TAG    "MFEA-NDK"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)


#endif //PANORAMA_ANDROID_MLOG_H
