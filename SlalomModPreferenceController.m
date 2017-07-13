#define KILL_PROCESS
#import <UIKit/UIKit.h>
#import <Cephei/HBListController.h>
#import <Preferences/PSSpecifier.h>
#import <Social/Social.h>
#include <sys/sysctl.h>
#import "Slalom.h"
#import "Slalom.x"
#import <Cephei/HBAppearanceSettings.h>
#import "../PSPrefs.x"

DeclarePrefs()
DeclareGetter()

@interface SlalomModGuideViewController : UIViewController
@end

@implementation SlalomModGuideViewController

- (id)init {
    if (self == [super init]) {
        UITextView *guide = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
        guide.text = @"	iOS Slo-mo videos are videos with \"slo-mo file\" that stores the data of video slow part. \
So simply uploading these videos by unsupported services like Instagram and Facebook (or grabbing only video file) may not work. \
But with this tweak, you can re-export the slo-mo videos as a new \"slo-mo applied\" video. To do that, go to the album, the video you want to reexport, then\n\
A. Tap the \"Save Slo-mo\" (or \"...\") button at top-right to save a new video. (iOS 7-8)\n\
B. Tap \"Done\" button at bottom-right to save a new video if you want. (iOS 9+)\n\n\
🔷 Force Slo-mo for all videos\n\
	If this enabled, the system will recognize any videos as Slo-mo.\n\n\
🔶 Slo-mo rate\n\
	Set the factor of the slo-mo region of your video.\n\
For example, the default value is 0.25, if fps is set to 60, the slow part of the video will be played at 60 x 0.25 = 15 fps.\n\
	Larger values give faster playback, but worse slo-mo experience.\n\n\
🔷 Auto hide\n\
	Hide the fps indicator in Slo-mo mode when recording.\n\n\
🔶 FPS gestures\n\
	Show FPS setting alert (Single tap), or auto set FPS to its maximum. (Double tap)\n\
	⭕ This option enabled will disable the iPhone 6 Plus's default FPS toggle gesture. (120 or 240)\n\n\
🔷 Slo-mo ramp volume\n\
	Set the volume of the slow part of slo-mo videos. The recommended value is about 2.0 if you want to keep video sound level.\n\n\
🔶 Fake framerate\n\
	Fake the FPS indicator number in Slo-mo mode.\n\n\
🔷 Slo-mo Quality for Mail app\n\
	There is the reason for creating this option, because exporting videos by email won't support the \"passthrough\" mode (no video touching, no change in quality) this time, it also causes the \"Sharing interrupted\" error message. So the best solution is using the highest available exporting mode instead.\n\n\
 Apparently spotted in iOS 8, changes of slow motion rate and volume are only applied when assetsd is reloaded. So you would want to reload assetsd after you set those properties.\
";
        guide.font = [UIFont systemFontOfSize:14];
        guide.editable = NO;
        self.view = guide;
        self.navigationItem.title = @"Slo-mo Mod Guide";
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:0 target:self action:@selector(dismissGuide)] autorelease];
    }
    return self;
}

- (void)dismissGuide {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface SlalomModPreferenceController : PSListController <UIAlertViewDelegate>
@property (nonatomic, retain) PSSpecifier *asSpec;
@property (nonatomic, retain) PSSpecifier *fpsSpec;
@end

@implementation SlalomModPreferenceController

HavePrefs()

- (void)masterSwitch:(id)value specifier:(PSSpecifier *)spec {
    [self setPreferenceValue:value specifier:spec];
    killProcess("Camera");
    if (isiOS7Up)
        killProcess("MobileSlideshow");
}

- (NSString *)model {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = (char *)malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    free(answer);
    return results;
}

- (void)reloadAS:(id)param {
    if (isiOS8Up)
        system("launchctl kickstart -k system/com.apple.assetsd");
    else {
        system("launchctl stop com.apple.assetsd");
        system("launchctl start com.apple.assetsd");
    }
}

HaveBanner2(TWEAK_NAME, UIColor.systemRedColor, @"Slow motion for all devices", nil)

- (id)init {
    if (self == [super init]) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = UIColor.systemRedColor;
        appearanceSettings.tableViewCellTextColor = UIColor.systemRedColor;
        appearanceSettings.invertedNavigationBar = YES;
        self.hb_appearanceSettings = appearanceSettings;
        UIButton *heart = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        UIImage *image = [[UIImage imageNamed:@"Heart" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SlalomModSettings.bundle"]] _flatImageWithColor:UIColor.whiteColor];
        [heart setImage:image forState:UIControlStateNormal];
        [heart sizeToFit];
        [heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:heart] autorelease];
    }
    return self;
}

- (void)love {
    SLComposeViewController *twitter = [[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] retain];
    twitter.initialText = @"#SlomoMod by @PoomSmart is really awesome!";
    if (twitter)
        [self.navigationController presentViewController:twitter animated:YES completion:nil];
    [twitter release];
}

- (void)showGuideView {
    SlalomModGuideViewController *guide = [[[SlalomModGuideViewController alloc] init] autorelease];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:guide] autorelease];
    nav.modalPresentationStyle = 2;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)hideKeyboard {
    [[super view] endEditing:YES];
}

- (void)showGuide:(id)param {
    [self showGuideView];
}

- (NSUInteger)maxCompatibleFPS {
    NSUInteger fps = maximumFPS();
    return fps == 0 ? 30 : fps;
}

- (void)showFPSWarningIfNeeded:(NSUInteger)fps {
    NSUInteger limitFPS = [self maxCompatibleFPS];
    if (fps > limitFPS || fps <= 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:TWEAK_NAME message:[NSString stringWithFormat:@"WARNING: %lu FPS is not compatible.\nThe recommended is %lu FPS.", (unsigned long)fps, (unsigned long)limitFPS] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Ok, set it", nil];
        alert.tag = 112299;
        [alert show];
        [alert release];
    }
}

- (void)setFPS:(id)param {
    [self hideKeyboard];
}

- (void)autoSetFPS {
    [self setPreferenceValue:@([self maxCompatibleFPS]) specifier:self.fpsSpec];
    [self reloadSpecifier:self.fpsSpec animated:YES];
    [self hideKeyboard];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 112299) {
        if (buttonIndex == 1)
            [self autoSetFPS];
    }
}

- (void)setFPSValue:(id)value specifier:(PSSpecifier *)spec {
    [self showFPSWarningIfNeeded:[value intValue]];
    [self setPreferenceValue:value specifier:spec];
}

- (void)setFakeFPSValue:(id)value specifier:(PSSpecifier *)spec {
    NSUInteger fps = [value intValue];
    if (fps <= 1)
        fps = 1;
    [self setPreferenceValue:@(fps) specifier:spec];
    [self reloadSpecifier:spec animated:NO];
}

- (void)autoFPS:(id)param {
    [self autoSetFPS];
}

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specs = [NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"Sla" target:self]];
        NSUInteger fps = intForKey(MogulFramerateKey, maximumFPS());
        [self showFPSWarningIfNeeded:fps];
        for (PSSpecifier *spec in specs) {
            NSString *Id = [spec identifier];
            if ([Id isEqualToString:@"fps"])
                self.fpsSpec = spec;
            else if ([Id isEqualToString:@"as"])
                self.asSpec = spec;
        }
        _specifiers = specs.copy;
    }
    return _specifiers;
}

@end
