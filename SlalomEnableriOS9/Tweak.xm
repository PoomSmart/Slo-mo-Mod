#import "../Slalom.h"
#import "../SlalomUtilities.h"
#import "../SlalomHelper.h"
#import "../Dy.h"
#import "../Dy.x"
#import <UIKit/UIImage+Private.h>
#import <sys/utsname.h>

AVCaptureFigVideoDevice *dev;

%hook CAMCaptureEngine

- (AVCaptureFigVideoDevice *)backCameraDevice {
    return dev = %orig;
}

%end

%group Legacy

%hook CAMCaptureCapabilities

- (BOOL)isSupportedSlomoModeConfiguration:(NSInteger)config forDevice:(NSInteger)device {
    BOOL orig = %orig;
    if (!orig && (config == 1 || config == 2) && device == 0)
        return YES;
    return orig;
}

%end

%hook CAMViewfinderViewController

- (NSInteger)_videoConfigurationForMode:(NSInteger)mode device:(NSInteger)device {
    NSInteger config = %orig;
    if (config == 0 && mode == 2 && device == 0)
        return 1;
    return config;
}

%end

%hook AVCaptureDevice

- (AVCaptureDeviceFormat *)cameraVideoFormatForVideoConfiguration:(NSInteger)config {
    return (config == 1 || config == 2) ? [SoftSlalomUtilities bestDeviceFormat2:self] : %orig;
}

%end

%end

NSInteger _fps = -1;

%hook CAMFramerateIndicatorView

- (NSInteger)_framesPerSecond {
    return FakeFPS ? aFPS : _fps != -1 ? _fps : %orig;
}

%new
- (void)setFramesPerSecond:(NSInteger)fps {
    MSHookIvar<UILabel *>(self, "__topLabel").text = [NSString stringWithFormat:@"%ld", (long)fps];
    _fps = fps;
    [self _updateLabels];
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _alertView_clickedButtonAtIndex(alertView, buttonIndex, self);
}

%new
- (void)sm_setFPS:(NSUInteger)fps {
    [self setFramesPerSecond:fps];
    if (dev) {
        [dev lockForConfiguration:nil];
        [dev setActiveVideoMinFrameDuration:CMTimeMake(1, fps)];
        [dev setActiveVideoMaxFrameDuration:CMTimeMake(1, fps)];
        [dev unlockForConfiguration];
    }
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

%hook CAMViewfinderViewController

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)_startCapturingVideoWithRequest:(id)arg1 {
    %orig;
    if (self._currentMode == 2)
        self._framerateIndicatorView.hidden = hideIndicator;
}

- (void)_stopCapturingVideo {
    %orig;
    if (self._currentMode == 2)
        self._framerateIndicatorView.hidden = NO;
}

%end

%group Photos

%hook PFSlowMotionUtilities

+ (NSString *)exportPresetForAsset:(id)asset preferredPreset:(NSString *)preset {
    if ([preset hasPrefix:@"AVAssetExportPresetMail"] && mailMax == 1)
        return %orig(asset, @"AVAssetExportPresetHighestQuality");
    return %orig(asset, AVAssetExportPresetPassthrough);
}

+ (void)configureExportSession:(AVAssetExportSession *)session forcePreciseConversion:(BOOL)precise {
    %orig;
    [session setMinVideoFrameDuration:CMTimeMake(1, MogulFrameRate)];
}

%end

%hook PFSlowMotionConfiguration

- (float)volumeDuringSlowMotion {
    return volumeRamp;
}

- (float)volumeDuringRampToSlowMotion {
    return volumeRamp;
}

%end

%hook PFVideoAdjustments

+ (float)defaultSlowMotionRateForNominalFrameRate:(float)framerate {
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

- (UIImage *)_badgeImageForVideoSubtype:(NSUInteger)subtype {
    return ForceSlalom ? [UIImage pu_PhotosUIImageNamed:@"PUBadgeSlomo"] : %orig;
}

%end

%hook PUBadgeManager

- (long long)_badgeTypeForPLAsset:(PLManagedAsset *)asset size:(long long)a2 {
    return ForceSlalom && [asset isVideo] ? 7 : %orig;
}

%end

%hook PLVideoView

- (BOOL)_shouldShowSlalomEditor {
    BOOL isMogul = [MSHookIvar<PLManagedAsset *>(self, "_videoCameraImage") isMogul];
    return ForceSlalom || isMogul ? YES : %orig;
}

%end

%hook PUVideoEditViewController

%new
- (void)se_saveSlomo {
    [SoftSlalomHelper saveSlomo:self.view videoView:nil asset:self._videoAsset.pl_managedAsset PU:YES];
}

%new
- (void)se_override {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            [NSString stringWithFormat:@"%@ & Done", SAVE_TEXT],
                            @"Done", nil];
    sheet.tag = 95969596;
    [sheet showInView:self.view];
    [sheet release];
}

- (void)_updateButtons {
    %orig;
    if (MSHookIvar<NSInteger>(self, "_mainButtonAction") == 1) {
        UIButton *btn = MSHookIvar<UIButton *>(self, "_mainActionButton");
        [btn removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [btn addTarget:self action:@selector(se_override) forControlEvents:0x40];
    }
}

%new
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (popup.tag == 95969596)
        [SoftSlalomHelper slalomActionSheet2:self popup:popup buttonIndex:buttonIndex];
}

%end

%hook PUPhotoBrowserController

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

%end

%group assetsd

%hook PLManagedAsset

- (BOOL)setVideoInfoFromFileAtURL:(NSURL *)fileURL fullSizeRenderURL:(NSURL *)fullSizeURL overwriteOriginalProperties:(BOOL)overwrite {
    BOOL orig = %orig;
    NSURL *url = fullSizeURL ? fullSizeURL : fileURL;
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    float fps = track.nominalFrameRate;
    short int slalomType = 3;
    if (ForceSlalom || self.savedAssetType == slalomType || fps > 30)
        self.kindSubtype = 0x65;
    return orig;
}

%end

%end

%hook PLManagedAsset

- (BOOL)isMogul {
    return [self isVideo] && ForceSlalom ? YES : %orig;
}

%end

%group MG

extern "C" Boolean MGGetBoolAnswer(CFStringRef);
%hookf(Boolean, MGGetBoolAnswer, CFStringRef key) {
    if (CFStringEqual(key, CFSTR("RearFacingCameraHFRCapability")))
        return YES;
    return %orig(key);
}

%end

%ctor {
    callback();
    if (EnableSlalom) {
        HaveObserver();
        if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.mobileslideshow"]) {
            dlopen("/System/Library/Frameworks/PhotosUI.framework/PhotosUI", RTLD_LAZY);
            %init(Photos);
        }
        %init(MG);
        if ([@"assetsd" isEqualToString:[NSProcessInfo processInfo].processName]) {
            %init(assetsd);
        } else {
            if ([SoftSlalomUtilities isLegacyDevice]) {
                %init(Legacy);
            }
            %init;
        }
    }
}
