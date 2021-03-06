#import "../Slalom.h"
#import "../SlalomUtilities.h"
#import "../SlalomHelper.h"
#import "../Dy.h"
#import "../Dy.x"

%hook PLCameraView

- (BOOL)canBecomeFirstResponder {
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

%hook PLCameraController

- (double)mogulFrameRate {
    return (double)MogulFrameRate;
}

- (AVCaptureDeviceFormat *)_mogulFormatFromDevice:(AVCaptureFigVideoDevice *)device {
    AVCaptureDeviceFormat *format = [SoftSlalomUtilities bestDeviceFormat2:device further:NO];
    return format ? format : %orig;
}

%end

%hook PLSlalomConfiguration

- (void)setRate:(float)r {
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

+ (NSString *)exportPresetForAsset:(id)asset preferredPreset:(NSString *)preset {
    if ([preset hasPrefix:@"AVAssetExportPresetMail"] && mailMax == 1)
        return %orig(asset, @"AVAssetExportPresetHighestQuality");
    return %orig(asset, AVAssetExportPresetPassthrough);
}

+ (void)configureExportSession:(AVAssetExportSession *)session forcePreciseConversion:(BOOL)precise {
    %orig;
    session.minVideoFrameDuration = CMTimeMake(1, MogulFrameRate);
}

%end

%hook NSUserDefaults

- (BOOL)boolForKey:(NSString *)name {
    return [name isEqualToString:@"PLDebugCowbell"] ? YES : %orig;
}

%end

%hook CAMSlalomIndicatorView

- (void)setFramesPerSecond:(NSInteger)fps {
    %orig(FakeFPS ? aFPS : fps);
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _alertView_clickedButtonAtIndex(alertView, buttonIndex, self);
}

%new
- (void)sm_setFPS:(NSUInteger)fps {
    [self setFramesPerSecond:fps];
    AVCaptureDevice *device = [(PLCameraController *) cameraInstance ()currentDevice];
    [device lockForConfiguration:nil];
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, fps)];
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, fps)];
    [device unlockForConfiguration];
}

%new
- (void)autoSetFPS:(UIGestureRecognizer *)sender {
    [self sm_setFPS:(NSUInteger)[SoftSlalomUtilities maximumFPS]];
}

%new
- (void)setFPS:(UIGestureRecognizer *)sender {
    _setFPS(self);
}

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    if (indicatorTap) {
        UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autoSetFPS:)];
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

- (BOOL)_shouldShowSlalomEditor {
    return (ForceSlalom || [MSHookIvar<PLManagedAsset *>(self, "_videoCameraImage") isMogul]) ? YES : %orig;
}

%end

%hook PLPhotoBrowserController

- (void)updateOverlaysAnimated:(BOOL)animated {
    %orig;
    [SoftSlalomHelper updateOverlays:self.currentVideoView isVideo:[[self currentAsset] isVideo] isEditingVideo:[self isEditingVideo] isCameraApp:[self isCameraApp] navigationItems:self.navigationBar.items animated:animated target:self];
}

%new
- (void)se_saveSlomo {
    [SoftSlalomHelper saveSlomo:self.view videoView:self.currentVideoView asset:self.currentVideoView.videoCameraImage PU:NO];
}

%new
- (void)se_multipleOptions {
    [SoftSlalomHelper slalomMultipleOptions:self.view target:self];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (popup.tag == 95969596)
        [SoftSlalomHelper slalomActionSheet:self popup:popup buttonIndex:buttonIndex];
    else
        %orig;
}

%end

%hook PLPublishingAgent

%new
- (void)se_video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [SoftSlalomHelper clearHUD];
}

- (void)videoRemakerDidEndRemaking:(id)arg1 temporaryPath:(NSString *)mediaPath {
    if ([SoftSlalomHelper buttonAction]) {
        [SoftSlalomHelper setButtonAction:NO];
        if (mediaPath)
            UISaveVideoAtPathToSavedPhotosAlbum(mediaPath, self, @selector(se_video:didFinishSavingWithError:contextInfo:), nil);
    }
    %orig;
}

%end

%hook CAMPadApplicationSpec

%new
- (BOOL)shouldCreateSlalomIndicator {
    return YES;
}

%end

%hook CAMBottomBar

- (void)_layoutForVerticalOrientation {
    %orig;
    CGRect frame = self.frame;
    CGFloat midX = frame.size.width / 2 - 20.0;
    self.slalomIndicatorView.frame = CGRectMake(midX, 20.0, 40.0, 40.0);
}

%end

%hook CAMCameraSpec

- (BOOL)shouldCreateSlalomIndicator {
    return YES;
}

- (BOOL)isPhone {
    return padHook ? YES : %orig;
}

%end

extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
    if (CFStringEqual(key, CFSTR("RearFacingCameraHFRCapability")))
        return YES;
    return %orig(key);
}

%ctor {
    callback();
    if (EnableSlalom) {
        HaveObserver();
        %init;
    }
}
