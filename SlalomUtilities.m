#import "SlalomUtilities.h"

@implementation SlalomUtilities

+ (NSUInteger)bestFrameRateRangeIndex:(AVCaptureDevice *)device {
    NSUInteger formatIndex = 0;
    AVFrameRateRange *bestFrameRateRange = nil;
    NSArray *formats = device.formats;
    for (NSUInteger i = 0; i < formats.count; i++) {
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
    NSArray *formats = device.formats;
    AVFrameRateRange *bestRange = formats[[self bestFrameRateRangeIndex:device]];
    if (bestRange)
        limitFPS = bestRange.maxFrameRate;
    return (NSInteger)limitFPS;
}

@end
