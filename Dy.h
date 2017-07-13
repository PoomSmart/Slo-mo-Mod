#import "../PS.h"
#import "SlalomMBProgressHUD.h"

@interface CAMSlalomIndicatorView (Addition)
- (void)autoSetFPS;
- (void)sm_setFPS:(NSUInteger)fps;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSUInteger)index;
@end

@interface CAMFramerateIndicatorView (Addition)
- (void)autoSetFPS;
- (void)sm_setFPS:(NSUInteger)fps;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSUInteger)index;
- (void)setFramesPerSecond:(NSInteger)fps;
@end

@interface PLPhotoBrowserController (Addition)
- (void)se_saveSlomo;
@end

@interface PUPhotoBrowserController (Addition)
- (void)se_saveSlomo;
@end

@interface PHAsset : NSObject
- (PLManagedAsset *)pl_managedAsset;
@end

@interface PUVideoEditViewController : UIViewController <UIActionSheetDelegate, photoBrowserDelegate>
- (PHAsset *)_videoAsset;
- (void)_handleMainActionButton:(id)arg1;
- (void)_handleSaveButton:(id)arg1;
@end

@interface PUVideoEditViewController (Addition)
- (void)se_saveSlomo;
@end

BOOL EnableSlalom;
BOOL indicatorTap;
BOOL ForceSlalom;
BOOL FakeFPS;
BOOL hideIndicator;
NSInteger mailMax;
BOOL padHook = NO;
NSUInteger MogulFrameRate;
double rate;
double volumeRamp;
NSInteger aFPS;

BOOL didShowNotCapableAlert = NO;

PLProgressHUD *seHUD = nil;
BOOL buttonAction = NO;
