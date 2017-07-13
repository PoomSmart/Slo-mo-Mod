#import <AVFoundation/AVFoundation.h>

AVFrameRateRange *bestFrameRateRange()
{
	AVFrameRateRange *bestFrameRateRange = nil;
	for (AVCaptureDeviceFormat *format in [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] formats]) {
		for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
			if (range.maxFrameRate > bestFrameRateRange.maxFrameRate) {
				bestFrameRateRange = range;
			}
		}
	}
	return bestFrameRateRange;
}

NSInteger maximumFPS()
{
	Float64 limitFPS = 30;
	AVFrameRateRange *bestRange = bestFrameRateRange();
    if (bestRange != nil)
    	limitFPS = bestRange.maxFrameRate;
    return (NSInteger)limitFPS;
}