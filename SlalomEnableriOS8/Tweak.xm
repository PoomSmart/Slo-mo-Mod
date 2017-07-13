#import "../Slalom.h"
#import "../Slalom.x"
#import "../Dy.h"
#import "../Dy.x"

%hook CAMCameraView

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)_slalomIndicatorTapped:(id)arg1 {
    if ([(CAMCaptureController *)[%c(CAMCaptureController) sharedInstance] mogulFrameRate] < 120)
        return;
    %orig;
}

- (void)_createSlalomIndicatorIfNecessary {
    padHook = YES;
    %orig;
    padHook = NO;
    if (indicatorTap) {
        for (UIGestureRecognizer *recognizer in self._bottomBar.slalomIndicatorView.gestureRecognizers) {
            Ivar targetsIvar = class_getInstanceVariable([UIGestureRecognizer class], "_targets");
            id targetActionPairs = object_getIvar(recognizer, targetsIvar);
            Class targetActionPairClass = NSClassFromString(@"UIGestureRecognizerTarget");
            Ivar actionIvar = class_getInstanceVariable(targetActionPairClass, "_action");
            for (id targetActionPair in targetActionPairs) {
                SEL action = (SEL)object_getIvar(targetActionPair, actionIvar);
                if ([NSStringFromSelector(action) isEqualToString:@"_slalomIndicatorTapped:"])
                    [self._bottomBar.slalomIndicatorView removeGestureRecognizer:recognizer];
            }
        }
    }
}

- (void)_showControlsForCapturingVideoAnimated:(BOOL)animated {
    %orig;
    if (self.cameraMode == 2)
        self._bottomBar.slalomIndicatorView.hidden = hideIndicator;
}

- (void)_hideControlsForCapturingVideoAnimated:(BOOL)animated {
    %orig;
    if (self.cameraMode == 2)
        self._bottomBar.slalomIndicatorView.hidden = NO;
}

%end

%hook CAMApplicationViewController

- (void)_kickoffCameraControllerPreview
{
    if (!slalom_isCapableOfFPS(MogulFrameRate)) {
        showNotCapableFPSAlert(self.view);
        return;
    }
    %orig;
}

%end

%hook PFSlowMotionUtilities

+ (NSString *)exportPresetForAsset: (id)asset preferredPreset: (NSString *)preset
{
    if ([preset hasPrefix:@"AVAssetExportPresetMail"]) {
        if (mailMax == 1)
            return %orig(asset, @"AVAssetExportPresetHighestQuality");
    }
    return %orig(asset, AVAssetExportPresetPassthrough);
}

+ (void)configureExportSession:(AVAssetExportSession *)session forcePreciseConversion:(BOOL)precise {
    %orig;
    [session setMinVideoFrameDuration:CMTimeMake(1, MogulFrameRate)];
}

%end

BOOL noHigh = NO;

%hook CAMCaptureController

- (void)_startPreview: (id)arg1
{
    if (didShowNotCapableAlert)
        return;
    %orig;
}

- (double)mogulFrameRate {
    return (double)MogulFrameRate;
}

- (void)_configureSessionWithCameraMode:(int)mode cameraDevice:(int)device options:(id)options {
    noHigh = YES;
    %orig;
    noHigh = NO;
}

- (AVCaptureDeviceFormat *)_mogulFormatFromDevice:(AVCaptureFigVideoDevice *)device frameRate:(BOOL)fps {
    if ([self mogulFrameRate] > 60)
        return %orig;
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
    AVCaptureDeviceFormat *mogulFormat = formats[formatIndex];
    AVFrameRateRange *range = mogulFormat.videoSupportedFrameRateRanges[0];
    Float64 maxFrameRate = range.maxFrameRate;
    if (maxFrameRate > 30)
        return mogulFormat;
    for (NSUInteger i = 0; i < formats.count; i++) {
        AVCaptureDeviceFormat *format = formats[i];
        if ([format.mediaType isEqualToString:AVMediaTypeVideo]) {
            CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
            if (dimension.width == 1280 && dimension.height == 720)
                formatIndex = [formats indexOfObject:format];
        }
    }
    AVCaptureDeviceFormat *mogulFormat2 = formats[formatIndex];
    return mogulFormat2;
}

%end

%hook PFSlowMotionConfiguration

- (float)volumeDuringSlowMotion
{
    return volumeRamp;
}

- (float)volumeDuringRampToSlowMotion {
    return volumeRamp;
}

%end

%hook PFVideoAVObjectBuilder

- (id)initWithVideoAsset: (AVAsset *)videoAsset videoAdjustments: (PFVideoAdjustments *)videoAdjustments
{
    self = %orig;
    if (self) {
        if (ForceSlalom) {
            if (videoAsset != nil) {
                CMTime duration = videoAsset.duration;
                CMTimeRange range = [%c(PFVideoAdjustments) defaultSlowMotionTimeRangeForDuration: duration];
                if (videoAdjustments == nil) {
                    float nominalFrameRate = [(AVAssetTrack *)[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] nominalFrameRate];
                    float rate = [%c(PFVideoAdjustments) defaultSlowMotionRateForNominalFrameRate: nominalFrameRate];
                    PFVideoAdjustments *newVideoAdjustments = [[%c(PFVideoAdjustments) alloc] initWithSlowMotionTimeRange:range rate:rate];
                    MSHookIvar<PFVideoAdjustments *>(self, "_videoAdjustments") = [newVideoAdjustments copy];
                    [newVideoAdjustments release];
                }
                MSHookIvar<PFVideoAdjustments *>(self, "_videoAdjustments").slowMotionTimeRange = range;
            }
        }
    }
    return self;
}

%end

%hook PFVideoAdjustments

+ (float)defaultSlowMotionRateForNominalFrameRate: (float)framerate
{
    return rate;
}

- (float)slowMotionRate {
    return rate;
}

- (void)setSlowMotionRate:(float)origRate {
    %orig(rate);
}

%end

%hook PUVideoBannerView

- (UIImage *)_badgeImageForVideoSubtype: (NSUInteger)subtype
{
    return ForceSlalom ? [UIImage pu_PhotosUIImageNamed:@"PUSlalomBadgeIcon"] : %orig;
}

%end

%group assetsd

%hook PLManagedAsset

- (BOOL)setVideoInfoFromFileAtURL: (NSURL *)fileURL fullSizeRenderURL: (NSURL *)fullSizeURL overwriteOriginalProperties: (BOOL)overwrite
{
    BOOL orig = %orig;
    NSURL *url = fullSizeURL ? fullSizeURL : fileURL;
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    float fps = track.nominalFrameRate;
    short int slalomType = 3;
    if (fps >= MogulFrameRate || ForceSlalom)
        self.kindSubtype = 0x65;
    if (self.hasAdjustments && self.savedAssetType == slalomType)
        self.kindSubtype = 0x65;
    return orig;
}

%end

%end

MSHook(CMTime, CMTimeMake, int64_t value, int32_t timescale){
    return _CMTimeMake(value, noHigh && (timescale > 60) ? MogulFrameRate : timescale);
}

%hook CAMCameraSpec

- (BOOL)shouldCreateSlalomIndicator
{
    return YES;
}

- (BOOL)isPhone {
    return padHook ? YES : %orig;
}

%end

%hook CAMPadApplicationSpec

%new
- (BOOL)shouldCreateSlalomIndicator
{
    return YES;
}

%end

%hook CAMBottomBar

- (void)_layoutForVerticalOrientation
{
    %orig;
    CGRect frame = self.frame;
    CGFloat midX = frame.size.width/2 - 20.0f;
    [self.slalomIndicatorView setFrame:CGRectMake(midX, 20.0f, 40.0f, 40.0f)];
}

%end

%hook PLManagedAsset

- (BOOL)isMogul
{
    BOOL isVideo = [self isVideo];
    if (isVideo) {
        if (ForceSlalom)
            return YES;
    }
    return %orig;
}

%end

%hook CAMSlalomIndicatorView

- (void)setFramesPerSecond: (NSInteger)fps
{
    %orig(FakeFPS ? aFPS : fps);
}

%new
- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    _alertView_clickedButtonAtIndex(alertView, buttonIndex, self);
}

%new
- (void)sm_setFPS: (NSUInteger)fps
{
    [self setFramesPerSecond:fps];
    AVCaptureDevice *device = [cameraInstance() currentDevice];
    [device lockForConfiguration:nil];
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, fps)];
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, fps)];
    [device unlockForConfiguration];
}

%new
- (void)autoSetFPS
{
    [self sm_setFPS:(NSUInteger)maximumFPS()];
}

%new
- (void)setFPS: (UIGestureRecognizer *)sender
{
    _setFPS(self);
}

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        if (indicatorTap) {
            UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoSetFPS)];
            doubleGesture.numberOfTapsRequired = 2;
            UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setFPS:)];
            singleGesture.numberOfTapsRequired = 1;
            [singleGesture requireGestureRecognizerToFail:doubleGesture];
            [self addGestureRecognizer:doubleGesture];
            [self addGestureRecognizer:singleGesture];
            [singleGesture release];
            [doubleGesture release];
        }
    }
    return self;
}

%end

%hook PLVideoView

- (BOOL)_shouldShowSlalomEditor
{
    BOOL orig = %orig;
    BOOL isMogul = [MSHookIvar<PLManagedAsset *>(self, "_videoCameraImage")isMogul];
    if (ForceSlalom || isMogul)
        return YES;
    return orig;
}

%end

%hook PLPhotoBrowserController

- (void)updateOverlaysAnimated: (BOOL)animated
{
    %orig;
    _updateOverlaysAnimated(self, animated);
}

%new
- (void)se_saveSlomo
{
    _se_saveSlomo(self);
}

%new
- (void)se_multipleOptions
{
    _se_multipleOptions(self);
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (popup.tag == 95969596)
        slalom_actionSheet(self, popup, buttonIndex);
    else
        %orig;
}

%end

%hook PLPublishingAgent

%new
- (void)se_video: (NSString *)videoPath didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo
{
    if (seHUD != nil) {
        [seHUD hide];
        [seHUD release];
    }
}

- (void)videoRemakerDidEndRemaking:(id)arg1 temporaryPath:(NSString *)mediaPath {
    if (buttonAction) {
        buttonAction = NO;
        if (mediaPath != nil)
            UISaveVideoAtPathToSavedPhotosAlbum(mediaPath, self, @selector(se_video:didFinishSavingWithError:contextInfo:), nil);
    }
    %orig;
}

%end

#define k(key) CFEqual(string, CFSTR(key))

extern "C" Boolean MGGetBoolAnswer(CFStringRef);
MSHook(Boolean, MGGetBoolAnswer, CFStringRef string){
    if (k("RearFacingCameraHFRCapability"))
        return YES;
    return _MGGetBoolAnswer(string);
}

%ctor
{
    HaveObserver()
    callback();
    if (EnableSlalom) {
        MSHookFunction(MGGetBoolAnswer, MSHake(MGGetBoolAnswer));
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        NSUInteger count = args.count;
        BOOL process = NO;
        if (count != 0) {
            NSString *executablePath = args[0];
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                if ([processName isEqualToString:@"assetsd"]) {
                    process = YES;
                    %init(assetsd);
                }
            }
        }
        if (!process) {
            MSHookFunction(CMTimeMake, MSHake(CMTimeMake));
            %init;
        }
    }
}
