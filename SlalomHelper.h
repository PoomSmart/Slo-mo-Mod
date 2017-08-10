#define UIFUNCTIONS_NOT_C
#import "Slalom.h"
#import <objc/runtime.h>

static BOOL buttonAction;
static PLProgressHUD *seHUD;

@interface SlalomHelper : NSObject
+ (BOOL)buttonAction;
+ (void)setButtonAction:(BOOL)action;
+ (void)clearHUD;
+ (void)saveSlomo:(UIView *)showView videoView:(PLVideoView *)view asset:(PLManagedAsset *)asset PU:(BOOL)PU;
+ (void)slalomMultipleOptions:(UIView *)showView target:(id)target;
+ (void)slalomActionSheet:(UIViewController *)vc popup:(UIActionSheet *)popup buttonIndex:(NSInteger)buttonIndex;
+ (void)slalomActionSheet2:(PUVideoEditViewController *)vc popup:(UIActionSheet *)popup buttonIndex:(NSInteger)buttonIndex;
+ (void)updateOverlays:(PLVideoView *)videoView isVideo:(BOOL)isVideo isEditingVideo:(BOOL)isEditingVideo isCameraApp:(BOOL)isCameraApp navigationItems:(NSArray __OF(UINavigationItem *) *)items animated:(BOOL)animated target:(id)target;
@end

#define SoftSlalomHelper NSClassFromString(@"SlalomHelper")
