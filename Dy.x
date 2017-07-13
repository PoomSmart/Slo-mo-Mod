#import "Slalom.h"
#import "Slalom.x"
#import "Dy.h"
#import <objc/runtime.h>
#import "../PSPrefs.x"

#if NS_BLOCKS_AVAILABLE
typedef void (^PSCompletionBlock)();
#endif

static void showHUDWithBlock(id self, NSString *text, NSString *text2, double delay, PSCompletionBlock block) {
    SlalomMBProgressHUD *hud = [SlalomMBProgressHUD showHUDAddedTo:self animated:YES];
    hud.margin = 15.0f;
    hud.color = [UIColor whiteColor];
    hud.labelColor = [UIColor blackColor];
    hud.detailsLabelColor = [UIColor blackColor];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.detailsLabelText = text2;
    hud.removeFromSuperViewOnHide = YES;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SlalomMBProgressHUD hideAllHUDsForView:self animated:YES];
        if (block != NULL)
            block();
    });
}

static void showHUD(id self, NSString *text, NSString *text2, double delay) {
    showHUDWithBlock(self, text, text2, delay, NULL);
}

static BOOL slalom_isCapableOfFPS(double fps) {
    if (fps <= 1)
        return NO;
    return fps <= maximumFPS();
}

static NSObject <cameraControllerDelegate> *cameraInstance() {
    if (objc_getClass("CAMCaptureController"))
        return (CAMCaptureController *)[objc_getClass("CAMCaptureController") sharedInstance];
    return (PLCameraController *)[objc_getClass("PLCameraController") sharedInstance];
}

UIView <cameraViewDelegate> *cameraView(UIView *view) {
    return isiOS9Up ? (UIView <cameraViewDelegate> *)(view.superview.superview) : [cameraInstance() delegate];
}

static void showNotCapableFPSAlert(id self) {
    showHUD(self, TWEAK_NAME, [NSString stringWithFormat:@"❗ Unsupported FPS: %ld\nHead to settings to change this.", (long)MogulFrameRate], 10);
    didShowNotCapableAlert = YES;
}

static void __se_saveSlomo(UIViewController <photoBrowserDelegate> *self, PLVideoView *view, PLManagedAsset *asset, BOOL PU) {
    BOOL cannotSave = NO;
    if (view == nil)
        cannotSave = !PU;
    else {
        id asset;
        object_getInstanceVariable(view, "_videoCameraImage", (void * *)&asset);
        if (![view canEdit] || ![view _canAccessVideo] || ![view _mediaIsPlayable] || ![view _mediaIsVideo] || ![asset isMogul])
            cannotSave = YES;
    }
    if (cannotSave) {
        showHUD(self.view, TWEAK_NAME, @"❗ The video is not ready for saving.", 3);
        return;
    }
    buttonAction = YES;
    seHUD = [[PLProgressHUD alloc] init];
    [seHUD setText:@"Saving Slo-mo..."];
    [seHUD showInView:self.view];
    PLPublishingAgent *saver = [PLPublishingAgent publishingAgentForBundleNamed:@"PublishToYouTube" toPublishMedia:asset];
    [saver setEnableHDUpload:YES];
    [saver setMediaIsHDVideo:YES];
    [saver setSelectedOption:1];
    [saver setRemakerMode:[saver _remakerModeForSelectedOption]];
    [saver _transcodeVideo:asset];
}

static void _se_saveSlomo(UIViewController <photoBrowserDelegate> *self) {
    __se_saveSlomo(self, self.currentVideoView, self.currentVideoView.videoCameraImage, NO);
}

static void _se_multipleOptions(UIViewController <UIActionSheetDelegate, photoBrowserDelegate> *self) {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            SAVE_TEXT,
                            @"Done", nil];
    sheet.tag = 95969596;
    [sheet showInView:self.view];
    [sheet release];
}

static void slalom_actionSheet(UIViewController <photoBrowserDelegate> *self, UIActionSheet *popup, NSInteger buttonIndex) {
    switch (buttonIndex) {
        case 0:
            [(id) self se_saveSlomo];
            break;
        case 1:
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
    }
}

static void _updateOverlaysAnimated(UIViewController <photoBrowserDelegate> *self, BOOL animated) {
    BOOL isVideo = [[self currentAsset] isVideo];
    if (isVideo) {
        PLVideoView *view = self.currentVideoView;
        if (view == nil)
            return;
        if (![view _shouldShowSlalomEditor])
            return;
        BOOL isCameraApp = [self isCameraApp];
        NSString *saveTitle = !isCameraApp ? SAVE_TEXT : @"...";
        SEL saveAction = !isCameraApp ? @selector(se_saveSlomo) : @selector(se_multipleOptions);
        UIBarButtonItem *slomoBtn = [[UIBarButtonItem alloc] initWithTitle:saveTitle style:UIBarButtonItemStylePlain target:self action:saveAction];
        for (UINavigationItem *item in self.navigationBar.items) {
            if (![self isEditingVideo])
                [item setRightBarButtonItem:slomoBtn animated:animated];
        }
        [slomoBtn release];
    }
}

static void _setFPS(UIView <slalomIndicatorViewDelegate> *self) {
    if (FakeFPS) {
        showHUD(cameraView(self), TWEAK_NAME, @"❗ Fake Framerate option is enabled, disable it first if you want to change this.", 3);
        return;
    }
    NSString *message = @"Enter new FPS";
    NSString *cancel = @"Cancel";
    NSString *set = @"Set";
    NSString *autoSet = @"Auto Set";
    UIAlertView *fpsInput7 = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:set, autoSet, nil];
    fpsInput7.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [fpsInput7 textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    alertTextField.textAlignment = NSTextAlignmentCenter;
    fpsInput7.tag = 5566;
    [fpsInput7 show];
    [fpsInput7 release];
}

static void _alertView_clickedButtonAtIndex(UIAlertView *alertView, NSInteger buttonIndex, UIView <slalomIndicatorViewDelegate> *self) {
    if (buttonIndex == 0)
        return;
    if (alertView.tag != 5566)
        return;
    NSUInteger fps = 60;
    switch (buttonIndex) {
        case 1:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            fps = textField.text.intValue;
            if (fps <= 1) {
                showHUDWithBlock(cameraView(self), TWEAK_NAME, @"❗ Invalid FPS.", 1.5, ^{
                    [alertView show];
                });
                return;
            }
            break;
        }
        case 2:
            fps = (NSUInteger)maximumFPS();
            break;
    }
    if (!slalom_isCapableOfFPS(fps)) {
        showHUDWithBlock(cameraView(self), TWEAK_NAME, @"❗ This FPS is not supported by the device.", 1.8, ^{
            [alertView show];
        });
        return;
    }
    [(id) self sm_setFPS:fps];
}

HaveCallback() {
    GetPrefs()
    GetBool2(EnableSlalom, YES)
    GetInt(MogulFrameRate, MogulFramerateKey, 60)
    GetBool2(ForceSlalom, NO)
    GetBool2(FakeFPS, NO)
    GetBool2(hideIndicator, NO)
    GetBool2(indicatorTap, YES)
    GetInt2(mailMax, 0)
    GetFloat2(rate, 0.25)
    GetFloat2(volumeRamp, 0.15)
    GetInt2(aFPS, 240)
}
