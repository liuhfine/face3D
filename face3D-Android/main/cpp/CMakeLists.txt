# Sets the minimum version of CMake required to build the native
# library. You should either keep the default value or only pass a
# value of 3.4.0 or lower.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds it for you.
# Gradle automatically packages shared libraries with your APK.
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -frtti -fexceptions")

add_library( # Sets the name of the library.
             SYRender

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             # Associated headers in the same location as their source
             # file are automatically included.
             	SYJni.cpp
	     	SYNRender.h
	     	SYNRender.cpp
		SYLoadObj.h
		SYLoadObj.cpp
		mLog.h
		SYCeres.h
		SYCeres.cpp)


# Specifies a path to native header files.
include_directories(
    eigen
    ceres-solver/internal
    ceres-solver/internal/ceres
    ceres-solver/include
    ceres-solver/config
    ceres-solver/internal/ceres/miniglog
)

add_definitions (-DCERES_NO_LAPACK
                 -DCERES_NO_SUITESPARSE
                 -DCERES_NO_CXSPARSE
                 -DCERES_STD_UNORDERED_MAP)

set(LIBCERES_DIR ${CMAKE_SOURCE_DIR}/../jniLibs)
add_library(ceres STATIC IMPORTED)
set_target_properties(ceres PROPERTIES IMPORTED_LOCATION ${LIBCERES_DIR}/${ANDROID_ABI}/libceres.a)

# Searches for a specified prebuilt library and stores the path as a
# variable. Because system libraries are included in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library( # Sets the name of the path variable.
              log-lib
	     

              # Specifies the name of the NDK library that
              # you want CMake to locate.
              log )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in the
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
                       SYRender
			           -ljnigraphics
			           -lGLESv2
			           -landroid
                       ceres
                       # Links the target library to the log library
                       # included in the NDK.
                       ${log-lib})
