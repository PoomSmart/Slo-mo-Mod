#import <AVFoundation/AVFoundation.h>

@interface SlalomUtilities : NSObject
+ (NSUInteger)bestFrameRateRangeIndex:(AVCaptureDevice *)device;
+ (AVCaptureDeviceFormat *)bestDeviceFormat:(AVCaptureDevice *)device;
+ (AVCaptureDeviceFormat *)bestDeviceFormat2:(AVCaptureDevice *)device further:(BOOL)further;
+ (AVCaptureDeviceFormat *)bestDeviceFormat2:(AVCaptureDevice *)device;
+ (NSInteger)maximumFPS;
+ (BOOL)isSupportedFPS:(double)fps;
@end

#define SoftSlalomUtilities NSClassFromString(@"SlalomUtilities")
