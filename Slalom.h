#define UNRESTRICTED_AVAILABILITY
#import "../PS.h"

#define TWEAK_NAME @"Slo-mo Mod"
#define SAVE_TEXT @"Save Slo-mo"

#define tweakIdentifier @"com.PS.SlalomMod"

#define EnableSlalomKey @"EnableSlalom"
#define MogulFramerateKey @"MogulFramerate"
#define ForceSlalomKey @"ForceSlalom"
#define FakeFPSKey @"FakeFPS"
#define hideIndicatorKey @"hideIndicator"
#define indicatorTapKey @"indicatorTap"
#define mailMaxKey @"mailMax"
#define rateKey @"rate"
#define volumeRampKey @"volumeRamp"
#define aFPSKey @"aFPS"

@interface CAMSlalomIndicatorView (Addition)
- (void)autoSetFPS:(UIGestureRecognizer *)sender;
- (void)sm_setFPS:(NSUInteger)fps;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSUInteger)index;
@end

@interface CAMFramerateIndicatorView (Addition)
- (void)autoSetFPS:(UIGestureRecognizer *)sender;
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

@interface PUVideoEditViewController (Addition)
- (void)se_saveSlomo;
@end
