#import "SlalomHelper.h"
#import "SlalomMBProgressHUD.h"

@implementation SlalomHelper

+ (void)clearHUD {
    if (seHUD) {
        [seHUD hide];
        [seHUD release];
    }
}

+ (void)saveSlomo:(UIView *)showView videoView:(PLVideoView *)view asset:(PLManagedAsset *)asset PU:(BOOL)PU {
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
        [SlalomMBProgressHUD showHUD:showView text:@"❗ The video is not ready for saving." delay:3];
        return;
    }
    [self setButtonAction:YES];
    seHUD = [[PLProgressHUD alloc] init];
    [seHUD setText:@"Saving Slo-mo..."];
    [seHUD showInView:showView];
    PLPublishingAgent *saver = [PLPublishingAgent publishingAgentForBundleNamed:@"PublishToYouTube" toPublishMedia:asset];
    [saver setEnableHDUpload:YES];
    [saver setMediaIsHDVideo:YES];
    [saver setSelectedOption:1];
    [saver setRemakerMode:[saver _remakerModeForSelectedOption]];
    [saver _transcodeVideo:asset];
}

+ (void)slalomMultipleOptions:(UIView *)showView target:(id)target {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:target cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            SAVE_TEXT,
                            @"Done", nil];
    sheet.tag = 95969596;
    [sheet showInView:showView];
    [sheet release];
}

+ (void)slalomActionSheet:(UIViewController *)vc popup:(UIActionSheet *)popup buttonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [(PLPhotoBrowserController *) vc se_saveSlomo];
            break;
        case 1:
            [vc dismissViewControllerAnimated:YES completion:NULL];
            break;
    }
}

+ (void)slalomActionSheet2:(PUVideoEditViewController *)vc popup:(UIActionSheet *)popup buttonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [vc se_saveSlomo];
        case 1:
            [vc _handleSaveButton:nil];
            break;
    }
}

+ (void)updateOverlays:(PLVideoView *)videoView isVideo:(BOOL)isVideo isEditingVideo:(BOOL)isEditingVideo isCameraApp:(BOOL)isCameraApp navigationItems:(NSArray __OF(UINavigationItem *) *)items animated:(BOOL)animated target:(id)target {
    if (isVideo) {
        if (videoView == nil || ![videoView _shouldShowSlalomEditor])
            return;
        NSString *saveTitle = !isCameraApp ? SAVE_TEXT : @"...";
        SEL saveAction = !isCameraApp ? @selector(se_saveSlomo) : @selector(se_multipleOptions);
        UIBarButtonItem *slomoBtn = [[UIBarButtonItem alloc] initWithTitle:saveTitle style:UIBarButtonItemStylePlain target:target action:saveAction];
        for (UINavigationItem *item in items) {
            if (!isEditingVideo)
                [item setRightBarButtonItem:slomoBtn animated:animated];
        }
        [slomoBtn release];
    }
}

+ (BOOL)buttonAction {
    return buttonAction;
}

+ (void)setButtonAction:(BOOL)action {
    buttonAction = action;
}

@end
