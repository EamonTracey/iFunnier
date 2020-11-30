#import "../include/IFPRootListController.h"

@implementation IFPRootListController

- (NSArray *)specifiers {

	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;

}

- (id)readPreferenceValue:(PSSpecifier*)specifier {

	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];

}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {

	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}

}

- (void)viewDidLoad {

	[super viewDidLoad];

	[self setConfettiView:[[ConfettiView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0, 0, 0)]];
	[[self view] addSubview:[self confettiView]];
	[self setAudioPlayer:[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:@"/Library/PreferenceBundles/iFunnierPreferences.bundle/fanfare.wav"] error:nil]];

}

- (void)copyBearerToken {

	// This is quite inefficient, but my best strategy without acquiring root
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *applicationDirectories = [fileManager contentsOfDirectoryAtPath:@"/var/mobile/Containers/Data/Application/" error:nil];
	NSString *potentialBearerTokenPath;
	for (NSString *applicationDirectory in applicationDirectories) {
		potentialBearerTokenPath = [NSString stringWithFormat:@"%@/%@/%@/%@", @"/var/mobile/Containers/Data/Application/", applicationDirectory, @"Documents", @"ifunnierbearertoken"];
		if ([fileManager fileExistsAtPath:potentialBearerTokenPath]) {
			NSString *bearerToken = [NSString stringWithContentsOfFile:potentialBearerTokenPath encoding:NSUTF8StringEncoding error:nil];
			[[UIPasteboard generalPasteboard] setString:bearerToken];
			[[[UINotificationFeedbackGenerator alloc] init] notificationOccurred:UINotificationFeedbackTypeSuccess];
			return;
		}
	}
	// No token found
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Token Found!" message:@"You may need to open iFunny for a second so iFunnier can retrieve the token." preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDestructive handler:nil];
	[alert addAction:okayAction];
	[self presentViewController:alert animated:YES completion:nil];

}

- (void)uninstalliFunny {

	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Would you really like to uninstall iFunny?" message:@"Please say yes!" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.eamontracey.ifunnier/uninstallifunny" object:nil userInfo:nil];
		if (![[self confettiView] isActive]) {
			[[self audioPlayer] play];
			[[self confettiView] startConfetti];
			[[self confettiView] performSelector:@selector(stopConfetti) withObject:self afterDelay:6];
		}
	}];
	UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:yesAction];
	[alert addAction:noAction];
	[self presentViewController:alert animated:YES completion:nil];

}

- (void)github {
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/EamonTracey/iFunnier"] options:@{} completionHandler:nil];

}

@end