#import <CoreMedia/CMTime.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/com.PS.SlalomMod.plist"
#define PreferencesChangedNotification "com.PS.SlalomMod.prefs"

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

/*BOOL g = NO;
#import <AVFoundation/AVFoundation.h>

%hook AVCaptureDeviceFormat

- (NSArray *)videoSupportedFrameRateRanges
{
	NSArray *ar = %orig;
	if (g) {
	return @[[AVFrameRateRange frameRateRangeWithMinRate:1 maxFrameRate:61]];
	}
	return ar;
}

%end

%hook AVFrameRateRange
- (BOOL)includesFrameDuration:(CMTime)du
{
	return YES;
}

%end

%hook AVCaptureFigVideoDevice

- (void)setActiveVideoMaxFrameDuration:(CMTime)time
{
	if (CMTimeCompare(time, CMTimeMake(1, 61)) == 0) {
		NSLog(@"HETT");
		[self _setActiveVideoMaxFrameDuration:time];
	} else
	%orig;
}

- (NSArray *)formats
{
	NSDictionary *sensorProperties = MSHookIvar<NSDictionary*>(self, "_sensorProperties");
	NSMutableDictionary *dict = [sensorProperties mutableCopy];
	NSMutableArray *arr = [[dict objectForKey:@"SupportedFormatsArray"] mutableCopy];
	for (int i=0; i <[arr count]; i++) {
		if (![(NSString *)[dict objectForKey:@"PortType"] isEqualToString:@"PortTypeBack"])
			break;
		NSDictionary *dict2 = [arr objectAtIndex:i];
		if ([dict2 objectForKey:@"VideoMaxFrameRate"] != nil && [[dict2 objectForKey:@"Width"] intValue] == 1280) {
			NSMutableDictionary *dic2 = [dict2 mutableCopy];
			if ([[dic2 objectForKey:@"VideoMaxFrameRate"] intValue] == 30) {
				[dic2 setObject:[NSNumber numberWithInt:61] forKey:@"VideoMaxFrameRate"];
				[dic2 setObject:[NSNumber numberWithInt:1] forKey:@"VideoIsBinned"];
				[dic2 removeObjectForKey:@"VideoDefaultMaxFrameRate"];
				[dic2 removeObjectForKey:@"VideoDefaultMinFrameRate"];
				[arr replaceObjectAtIndex:i withObject:dic2];
			}
		}
		//VideoLowLightContextSwitchSupported
		if ([dict2 objectForKey:@"VideoLowLightContextSwitchSupported"] != nil) {
			NSMutableDictionary *dic2 = [dict2 mutableCopy];
			if ([[dic2 objectForKey:@"VideoLowLightContextSwitchSupported"] intValue] == 0) {
				[dic2 setObject:[NSNumber numberWithInt:1] forKey:@"VideoLowLightContextSwitchSupported"];
				[arr replaceObjectAtIndex:i withObject:dic2];
			}
		}
	}
	[dict setObject:(NSArray *)arr forKey:@"SupportedFormatsArray"];
	sensorProperties = (NSDictionary *)dict;
	//NSLog(@"2 %@", sensorProperties);
	return %orig;
}

%end*/

%hook PLCameraController

/*- (void)_setupCamera
{
	g = YES;
	%orig;
	g = NO;
}*/

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

/*%hook AVAssetExportSession

- (BOOL)_canPerformFastFrameRateConversionWithPreset:(id)preset usingRemaker:(id)remaker
{
	return EnableSlalom ? YES : %orig;
}

%end*/

%hook PLSlalomUtilities

/*+ (void)configureExportSession:(AVAssetExportSession *)session forcePreciseConversion:(BOOL)arg2
{
	%log;
	//remaker_CanPerformFastFrameRateConversionWork
	%c(AVAssetExportSessionInternal);
	AVAssetExportSessionInternal *internal = MSHookIvar<AVAssetExportSessionInternal *>(session, "_exportSession");
	MSHookIvar<NSString *>(internal, "preset") = @"AVRemakerMode_PassThrough";
	%orig;
}*/

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
	#define k(key) CFEqual(string, CFSTR(key))
	if (k("RearFacingCameraHFRCapability") && EnableSlalom)
		return YES;
	return old_MGGetBoolAnswer(string);
}

Boolean (*old_isHighFrameRateSupported) ();

Boolean replaced_isHighFrameRateSupported() {
	return YES;
}


%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	pref();
	MSHookFunction(((BOOL *)MSFindSymbol(NULL, "_MGGetBoolAnswer")), (BOOL *)replaced_MGGetBoolAnswer, (BOOL **)&old_MGGetBoolAnswer);
	//MSHookFunction(((BOOL *)MSFindSymbol(NULL, "_isHighFrameRateSupported")), (BOOL *)replaced_isHighFrameRateSupported, (BOOL **)&old_isHighFrameRateSupported);
	%init;
	[pool drain];
}
