#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

CF_EXTERN_C_BEGIN

/**
 * @enum PoseDetectorMode
 * Pose detector modes.
 */
typedef NSInteger MLKPoseDetectorMode NS_TYPED_ENUM NS_SWIFT_NAME(PoseDetectorMode);

/** Optimized for single static images. */
extern const MLKPoseDetectorMode MLKPoseDetectorModeSingleImage;

/**
 * Optimized to expedite the processing of a streaming video by leveraging the results from previous
 * images.
 */
extern const MLKPoseDetectorMode MLKPoseDetectorModeStream;

/**
 * @enum PoseDetectorPerformanceMode
 * Pose detector performance modes.
 */
typedef NSInteger MLKPoseDetectorPerformanceMode NS_TYPED_ENUM
    NS_SWIFT_NAME(PoseDetectorPerformanceMode);

/**
 * Optimized for speed. Results may be less accurate, but will run faster by using a lite model.
 */
extern const MLKPoseDetectorPerformanceMode MLKPoseDetectorPerformanceModeFast;

/**
 * Optimized for accuracy. Results may run slower, but will be more accurate by using a full model.
 */
extern const MLKPoseDetectorPerformanceMode MLKPoseDetectorPerformanceModeAccurate;

CF_EXTERN_C_END

/** Options for specifying a pose detector. */
NS_SWIFT_NAME(PoseDetectorOptions)
@interface MLKPoseDetectorOptions : NSObject

/** The mode for the pose detector. The default value is `.stream`. */
@property(nonatomic) MLKPoseDetectorMode detectorMode;

/** The performance mode for the pose detector. The default value is `.fast`. */
@property(nonatomic) MLKPoseDetectorPerformanceMode performanceMode;

/** Creates a new instance. */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
