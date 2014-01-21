#import <CoreMedia/CMTime.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/com.PS.SlalomMod.plist"
#define PreferencesChangedNotification "com.PS.SlalomMod.prefs"
#define k(key) CFEqual(string, CFSTR(key))

static BOOL EnableSlalom = YES;
static BOOL ForceSlalom;
static double MogulFrameRate;
static float rate;
static float volumeRamp;

static void pref()
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	EnableSlalom = [dict objectForKey:@"EnableSlalom"] ? [[[NSDictionary dictionaryWithContentsOfFile:PREF_PATH] objectForKey:@"EnableSlalom"] boolValue] : YES;
	MogulFrameRate = [dict objectForKey:@"MogulFramerate"] ? [[dict objectForKey:@"MogulFramerate"] doubleValue] : 60;
	ForceSlalom = [[dict objectForKey:@"ForceSlalom"] boolValue];
	rate = [dict objectForKey:@"rate"] ? [[dict objectForKey:@"rate"] floatValue] : 0.25;
	volumeRamp = [dict objectForKey:@"volumeRamp"] ? [[dict objectForKey:@"volumeRamp"] floatValue] : 0.15;
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	system("killall Camera MobileSlideShow");
	pref();
}

%hook CAMCameraSpec

- (BOOL)shouldCreateSlalomIndicator
{
	return EnableSlalom ? YES : %orig;
}

%end

%hook NSUserDefaults

- (BOOL)boolForKey:(NSString *)name
{
	return EnableSlalom && [name isEqualToString:@"PLDebugCowbell"] ? YES : %orig;
}

%end

%hook PLCameraController

- (double)mogulFrameRate
{
	return MogulFrameRate;
}

%end

%hook PLManagedAsset

- (BOOL)isMogul
{
	return EnableSlalom && ForceSlalom ? YES : %orig;
}

%end

%hook PLVideoView

- (BOOL)allowSlalomEditor
{
	return EnableSlalom && ForceSlalom ? YES : %orig;
}

- (BOOL)_shouldShowSlalomEditor
{
	return EnableSlalom && ForceSlalom ? YES : %orig;
}

%end


%hook PLSlalomRangeMapperScaledRegion

- (float)rate
{
	return rate;
}

- (void)setRate:(float)r
{
	%orig(rate);
}

%end

%hook PLSlalomUtilities

+ (float)preferredTimeScale
{
	return rate;
}

%end

%hook PLSlalomConfiguration

- (float)rate
{
	return rate;
}

- (void)setRate:(float)r
{
	%orig(rate);
}

- (void)setVolumeDuringSlalom:(float)vol
{
	%orig(volumeRamp);
}


- (void)setVolumeDuringRampToSlalom:(float)vol
{
	%orig(volumeRamp);
}

%end

Boolean (*old_MGGetBoolAnswer)(CFStringRef);
Boolean replaced_MGGetBoolAnswer(CFStringRef string)
{
	if (k("RearFacingCameraHFRCapability") && EnableSlalom)
		return YES;
	return old_MGGetBoolAnswer(string);
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	pref();
	MSHookFunction(((BOOL *)MSFindSymbol(NULL, "_MGGetBoolAnswer")), (BOOL *)replaced_MGGetBoolAnswer, (BOOL **)&old_MGGetBoolAnswer);
	%init;
	[pool drain];
}
