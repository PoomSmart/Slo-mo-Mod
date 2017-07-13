#import "../Slalom.h"
#import "../Slalom.x"
#import "../Dy.h"
#import "../Dy.x"

%hook PLCameraView

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)_createSlalomIndicatorIfNecessary {
    padHook = YES;
    %orig;
    padHook = NO;
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

%hook PLApplicationCameraViewController

- (void)_kickoffCameraControllerPreview
{
    if (!slalom_isCapableOfFPS(MogulFrameRate)) {
        showNotCapableFPSAlert([self view]);
        return;
    }
    %orig;
}

%end

%hook PLCameraController

- (double)mogulFrameRate
{
    return (double)MogulFrameRate;
}

- (void)_startPreview:(id)arg1 {
    if (didShowNotCapableAlert)
        return;
    %orig;
}

- (AVCaptureDeviceFormat *)_mogulFormatFromDevice:(AVCaptureFigVideoDevice *)device {
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
    if (maxFrameRate <= 30)
        return %orig;
    return mogulFormat;
}

%end

%hook PLSlalomConfiguration

- (void)setRate: (float)r
{
    %orig(rate);
}

- (void)setVolumeDuringSlalom:(float)vol {
    %orig(volumeRamp);
}

- (void)setVolumeDuringRampToSlalom:(float)vol {
    %orig(volumeRamp);
}

%end

%hook PLSlalomUtilities

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
    session.minVideoFrameDuration = CMTimeMake(1, MogulFrameRate);
}

%end

%hook NSUserDefaults

- (BOOL)boolForKey: (NSString *)name
{
    return [name isEqualToString:@"PLDebugCowbell"] ? YES : %orig;
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
    if (self && indicatorTap) {
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
    return self;
}

%end

%hook PLVideoView

- (BOOL)_shouldShowSlalomEditor
{
    BOOL isMogul = [MSHookIvar<PLManagedAsset *>(self, "_videoCameraImage")isMogul];
    if (ForceSlalom || isMogul)
        return YES;
    return %orig;
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
    self.slalomIndicatorView.frame = CGRectMake(midX, 20.0f, 40.0f, 40.0f);
}

%end

%hook CAMCameraSpec

- (BOOL)shouldCreateSlalomIndicator
{
    return YES;
}

- (BOOL)isPhone {
    return padHook ? YES : %orig;
}

%end

%hook PLPhotoBrowserController

- (void)actionSheet: (UIActionSheet *)popup clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (popup.tag == 95969596)
        slalom_actionSheet(self, popup, buttonIndex);
    else
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
        %init;
    }
}
