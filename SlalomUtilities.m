#import "SlalomUtilities.h"
#import <sys/utsname.h>

@implementation SlalomUtilities

+ (BOOL)isLegacyDevice {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return [modelName isEqualToString:@"iPod5,1"] || [modelName hasPrefix:@"iPhone4"] || [modelName hasPrefix:@"iPhone5"] || [modelName hasPrefix:@"iPad2"] || [modelName hasPrefix:@"iPad3"] || [modelName isEqualToString:@"iPad4,4"] || [modelName isEqualToString:@"iPad4,5"] || [modelName isEqualToString:@"iPad4,6"];
}

+ (NSUInteger)bestFrameRateRangeIndex:(AVCaptureDevice *)device {
    NSUInteger formatIndex = 0;
    AVFrameRateRange *bestFrameRateRange = nil;
    NSArray *formats = device.formats;
    for (NSUInteger i = 0; i < formats.count; ++i) {
        AVCaptureDeviceFormat *format = formats[i];
        if ([format.mediaType isEqualToString:AVMediaTypeVideo]) {
            for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
                if (range.maxFrameRate > bestFrameRateRange.maxFrameRate) {
                    bestFrameRateRange = range;
                    formatIndex = i;
                }
            }
        }
    }
    return formatIndex;
}

+ (AVCaptureDeviceFormat *)bestDeviceFormat:(AVCaptureDevice *)device {
    return device.formats[[self bestFrameRateRangeIndex:device]];
}

+ (AVCaptureDeviceFormat *)bestDeviceFormat2:(AVCaptureDevice *)device further:(BOOL)further {
    AVCaptureDeviceFormat *mogulFormat = [self bestDeviceFormat:device];
    AVFrameRateRange *range = mogulFormat.videoSupportedFrameRateRanges[0];
    Float64 maxFrameRate = range.maxFrameRate;
    if (maxFrameRate > 30)
        return mogulFormat;
    if (!further)
        return nil;
    NSUInteger formatIndex = 0;
    NSArray *formats = device.formats;
    for (NSUInteger i = 0; i < formats.count; i++) {
        AVCaptureDeviceFormat *format = formats[i];
        if ([format.mediaType isEqualToString:AVMediaTypeVideo]) {
            CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
            if (dimension.width == 1280 && dimension.height == 720)
                formatIndex = [formats indexOfObject:format];
        }
    }
    return formats[formatIndex];
}

+ (AVCaptureDeviceFormat *)bestDeviceFormat2:(AVCaptureDevice *)device {
    return [self bestDeviceFormat2:device further:YES];
}

+ (NSInteger)maximumFPS {
    Float64 limitFPS = 30;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSArray <AVCaptureDeviceFormat *> *formats = device.formats;
    NSArray <AVFrameRateRange *> *ranges = formats[[self bestFrameRateRangeIndex:device]].videoSupportedFrameRateRanges;
    for (AVFrameRateRange *range in ranges)
        limitFPS = MAX(range.maxFrameRate, limitFPS);
    return (NSInteger)limitFPS;
}

+ (BOOL)isSupportedFPS:(double)fps {
    return fps > 1 && fps <= [self maximumFPS];
}

@end
