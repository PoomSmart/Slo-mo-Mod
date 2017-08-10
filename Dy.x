#import "Slalom.h"
#import "SlalomUtilities.h"
#import "Dy.h"
#import <objc/runtime.h>
#import "../PSPrefs.x"

static NSObject *cameraInstance() {
    return objc_getClass("CAMCaptureController") ? [objc_getClass("CAMCaptureController") sharedInstance] : [objc_getClass("PLCameraController") sharedInstance];
}

static UIView *cameraView(UIView *view) {
    return isiOS9Up ? view.superview.superview : [cameraInstance() performSelector:@selector(delegate)];
}

static void _setFPS(UIView *self) {
    if (FakeFPS) {
        [SoftSlalomMBProgressHUD showHUD:cameraView(self) text:@"❗ Fake Framerate option is enabled, disable it first if you want to change this." delay:3];
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

static void _alertView_clickedButtonAtIndex(UIAlertView *alertView, NSInteger buttonIndex, UIView *self) {
    if (buttonIndex == 0 || alertView.tag != 5566)
        return;
    NSUInteger fps = 60;
    switch (buttonIndex) {
        case 1:
        {
            UITextField *textField = [alertView textFieldAtIndex:0];
            fps = textField.text.intValue;
            if (fps <= 1) {
                [SoftSlalomMBProgressHUD showHUDWithBlock:cameraView(self) text:@"❗ Invalid FPS." delay:1.5 block:^{
                    [alertView show];
                }];
                return;
            }
            break;
        }
        case 2:
            fps = (NSUInteger)[SoftSlalomUtilities maximumFPS];
            break;
    }
    if (![SoftSlalomUtilities isSupportedFPS:fps]) {
        [SoftSlalomMBProgressHUD showHUDWithBlock:cameraView(self) text:@"❗ This FPS is not supported by the device." delay:1.8 block:^{
            [alertView show];
        }];
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
