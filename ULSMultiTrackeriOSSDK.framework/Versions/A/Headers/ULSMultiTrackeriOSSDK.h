//
//  ULSMultiTrackeriOSSDK.h
//  ULSMultiTrackeriOSSDK
//
//  Created by ulsee on 2/3/17.
//  Copyright © 2017 ulsee. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for ULSMultiTrackeriOSSDK.
FOUNDATION_EXPORT double ULSMultiTrackeriOSSDKVersionNumber;

//! Project version string for ULSMultiTrackeriOSSDK.
FOUNDATION_EXPORT const unsigned char ULSMultiTrackeriOSSDKVersionString[];

#define TRACKING_EAR


@interface ULSMultiTrackeriOSSDK : NSObject

/*!
 @method initFromFolder:withActivationKey:withActivationKey:
 @abstract
    Initialization of ULSMultiTrackeriOSSDK class object.
 
 @param path
    The path of the tracker resource. (The default resource name is ULSFaceTrackerAssets.bundle)
 @param key
    The valid key is essential to active the initialization of tracker object. The valid key is provided by ulsee.com.
 @param maxFaces
    Max number of face that want to be tracked.
 
 @result
    Return an object of ULSMultiTrackeriOSSDK class or nil value.
 */
- (id)initFromFolder:(NSString*)path withActivationKey:(NSString*)key withMaxFaces:(int)maxFaces;

/*!
 @method process:withFaceCount:withFaceRects:withRollAngle:
 @abstract
    This function gets facial tracking result from an input image captured by camera. This function should be called in each new frame generating.
    The face rectangle is expected to be in absolute coordinates.
 
 @param src
    The CVPixelBuferRef­-format frame captured from the camera. This frame is used to do the facial tracking process.
 @param count
    An integer value which indicates the number of faces are detected.
 @param faceRect
    The CGRect array of face rectangle value which returned from the method of AVCaptureMetadataOutputObjectsDelegate.
 @param radians
    The float array of roll angle value of the tracking face. This value would be got from the method of A VCaptureMetadataOutputObjectsDelegate.
 
 @result
    Return an integer that indicates the number of active faces.
 */
- (int) process:(CVPixelBufferRef)src
  withFaceCount:(int)count
  withFaceRects:(CGRect*)faceRect
  withRollAngle:(float*)radians;

- (int) process:(CVPixelBufferRef)src
  withFaceCount:(int)count;

/*!
 @method numberOfPoints
 @abstract
    Get the number of points in the shape.
 
 @result
    Returns an integer that indicates number of points in the shape.
 */
- (unsigned int)numberOfPoints;

/*!
 @method getShape:
 @abstract
    Get the facial landmarkers in 2D (x, y) from face index i.
 
 @param index
    The face index value.
 
 @result
    Return an array of floats [x0,y0,x1,y1,x2,y2......] for index(th) tracked face, or NULL.
 */
- (const float*)getShape:(int)index;

/*!
 @method getShape3D:
 @abstract
    Get the facial landmarkers in 3D (x, y, z) from face index i.
 
 @param index
    The face index value.
 
 @result
    Return an array of floats [x0,y0,x1,y1,x2,y2......] for index(th) tracked face, or NULL, in camera coordinate system.
 */
- (const float*)getShape3D:(int)index;

/*!
 @method getScaleInImage:
 @abstract
    Get face scale value of index(th) tracked face which relates to the initial 3D model.
    Weak-perspective camera model's scale parameter.
 
 @param index
    The face index value.
 
 @result
    Return a float value means scale of index(th) face.
 */
- (float) getScaleInImage:(int)index;

/*!
 @method getTranslationInImage:x:y:
 @abstract
    Get the X-axis and Y-axis translation in the image of a tracked face of the specified index.
    Data will be in order [x, y], to help find the centre-point of the face in the image, for accurate positioning.
 
 @param index
    The face index value.
 @param x
    Returned x value of centre-point of the face in the image.
 @param y
    Returned y value of centre-point of the face in the image.
 
 @result
    Return TRUE if the pose value was estimated. Return FALSE otherwise.
 */
- (BOOL) getTranslationInImage:(int)index x:(float*) x y:(float*)y;

/*!
 @method getRotationPitch:pitch:yaw:roll:
 @abstract
    This function is used to get the real time head pose pitch, yaw, roll value of the index(th) tracked face.
 
 @param index
    The face index value.
 @param pitch
    Returned picth value of the index(th) tracked face.
 @param yaw
    Returned yaw value of the index(th) tracked face.
 @param roll
    Returned roll value of the index(th) tracked face.
 
 @result
    Return TRUE if the pose is tracked for index(th) face. Return FALSE otherwise.
 */
- (BOOL) getRotationPitch:(const int)index pitch:(float*)pitch yaw:(float*)yaw roll:(float*)roll;

/*!
 @method getNewStablePoseIndex:pixelBuffer:
 @abstract
    This function is used to calculate the new pose values, for every tracked face of the specified index.
    This new algorithm is making POSE more stable when head is still with big open mouth or big open eyes.
    It's especially useful for avatar applications.
    You may skip the getNewStablePoseIndex function if you don't mind the POSE minor changes when open big mouth and eyes.
 
 @param index
    The face index value.
 @param pb
    The CVPixelBuferRef­-format frame captured from the camera. This frame is same as the used one to do the facial tracking process.
 
 @result
    Return an array of new pose [pitch, roll, yaw, scale].
 */
- (float *)getNewStablePoseIndex:(int)index pixelBuffer:(CVPixelBufferRef)pb;

/*!
 @method getShapeQuality:
 @abstract
    Get the shape quality from face index i.
 
 @param index
    The face index value.
 
 @result
    Return an array of shape quality [q0, q1, q2, q3...] indicates the quality of each landmark of the shape.
 */
- (const float*)getShapeQuality:(int)index;

/*!
 @method getPoseQuality
 @abstract
    Get pose quality from face index i.
 
 @param index
    The face index value.
 @result
    Return 0.7f while the pose value is not NULL. Return 0.0f otherwise.
 */
- (const float)getPoseQuality:(int)index;

/*!
 @method getPupilsLocation
 @abstract
    Get the pupil location of the index(th) face.
 
 @param index
    The face index value.
 
 @result
    Return an array of 4 floats (x,y)(x,y), or NULL.
 */
- (const float*)getPupilsLocation:(int)index;

/*!
 @method getGaze
 @abstract
    Get the gaze direction in left gaze (x, y, z) and right gaze (x, y, z) from face index i.
 
 @param index
    The face index value.
 
 @result
    Return an array of 6 floats (x,y,z)(x,y,z) with the direction of the gaze, or NULL.
 */
- (const float*)getGaze:(int)index;

/*!
 @method getTranslationIndex:x:y:z:focalLength:imageCentreX:imageCentreY:
 @abstract
    Get head center in 3D.
 
 @param index
    The face index value.
 @param x
    Returned x value of head center in 3D.
 @param y
    Returned y value of head center in 3D.
 @param z
    Returned z value of head center in 3D.
 @param focalLength
    The focal length value of camera. (Use 1000 as default.)
 @param imageCentreX
    The x-center value of the input pixel buffer of image.
 @param imageCentreY
    The y-center value of the input pixel buffer of image.
 */
- (void)getTranslationIndex:(int)index
                          x:(float *)x
                          y:(float *)y
                          z:(float *)z
                focalLength:(const float)focalLength
               imageCentreX:(const float)imageCentreX
               imageCentreY:(const float)imageCentreY;

/*!
 @method isTracking:
 @abstract
    Check if the index(th) face is tracked or not.
 
 @param index
    The face index value.
 @result
    Return TRUE while the index(th) face is tracked. Return FALSE otherwise.
 */
- (BOOL)isTracking:(int)index;

/*!
 @method setTrackerThreshold:
 @abstract
    Set the threshold value of tracker health value.
 
 @param threshold
    tracker health threshold. (default: 0.3f)
 */
- (void)setTrackerThreshold:(const float)threshold;


/*!
 @method resetTracker
 @abstract
    Reset the tracker(s).
 */
- (void)resetTracker;

/*!
 @method startFaceTracking:
 @abstract
    Start or stop face tracking process.
 
 @param isStart
    Set TRUE to start face tracking process. Set FALSE otherwise.
 */
- (void)startFaceTracking:(BOOL)isStart;

#ifdef TRACKING_EAR
/*!
 @method getNumberOfEarPoints
 @abstract
    Get the number of points in the ear shape.
 
 @result
    Returns an integer that indicates number of points in the ear shape.
 */
- (unsigned int)getNumberOfEarPoints;

/*!
 @method getLeftEarShape:
 @abstract
    Get the left ear landmarkers in 2D (x, y) from face index i. (Using front camera, it means the right ear on the screen)
 
 @param index
    The face index value.
 
 @result
    Return an array of left ear shape [x0,y0,x1,y1,x2,y2......] for index(th) tracked face, or NULL.
 */
- (const float*)getLeftEarShape:(int)index;

/*!
 @method getRightEarShape:
 @abstract
    Get the right ear landmarkers in 2D (x, y) from face index i. (Using front camera, it means the left ear on the screen)
 
 @param index
    The face index value.
 
 @result
    Return an array of right ear shape [x0,y0,x1,y1,x2,y2......] for index(th) tracked face, or NULL.
 */
- (const float*)getRightEarShape:(int)index;

/*!
 @method getLeftEarQuality:
 @abstract
    Get the left ear shape quality from face index i.
 
 @param index
    The face index value.
 
 @result
    Return an array of left ear shape quality [q0, q1, q2, q3...] indicates the quality of each landmark of the left ear shape.
 */
- (const float*)getLeftEarQuality:(int)index;

/*!
 @method getRightEarQuality:
 @abstract
    Get the right ear shape quality from face index i.
 
 @param index
    The face index value.
 
 @result
    Return an array of right ear shape quality [q0, q1, q2, q3...] indicates the quality of each landmark of the right ear shape.
 */
- (const float*)getRightEarQuality:(int)index;
#endif

@end
