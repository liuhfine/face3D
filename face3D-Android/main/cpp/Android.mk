# Copyright (C) 2013 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This is the shared library included by the JNI test app.
#
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	SYNRender.h
	SYNRender.cpp
	SYLoadObj.h
	SYLoadObj.cpp
	mLog.h
	SYCeres.h
	SYCeres.cpp
	./glm/detail/*.* ./glm/gtc/*.* ./glm/gtx/*.* ./glm/simd/*.* ./glm/*.*

LOCAL_LDLIBS := \
	-llog
	-lGLESv2
	-landroid

LOCAL_MODULE:= SYRender
include $(BUILD_SHARED_LIBRARY)
