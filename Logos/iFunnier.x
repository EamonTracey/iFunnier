#import "../include/iFunnier.h"

%hook AdvertisementAvailableServiceImpl

- (BOOL)isBannerEnabled {
	return blockAds ? NO : %orig;
}

- (BOOL)isNativeEnabled {
	return blockAds ? NO : %orig;
}

- (BOOL)isRewardEnabled {
	return blockAds ? NO : %orig;
}

%end

%hook FCSaveToGalleryActivity

- (void)save {
	NSURL *gifURL = (NSURL *)[self valueForKey:@"gifURL"];
	UIImage *image = (UIImage *)[self valueForKey:@"image"];
	if (gifURL) {
		%orig;
	} else if (image) {
		if (removeWatermarks) {
			CGRect cropRect = CGRectMake(0, 0, image.size.width, image.size.height - 20);
			CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
			UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
			CGImageRelease(imageRef);
			UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
		} else {
			%orig;
		}
	} else {
		NSData *contentData = [[[[[%c(FNApplicationController) instance] adViewController] topViewController] activeCell] contentData];
		NSString *ifunnyDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", ifunnyDocumentsDirectory, @"ifunniertmp.mp4"];
		[contentData writeToFile:tmpPath atomically:YES];
		[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
			[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:tmpPath]];
		} completionHandler:^(BOOL success, NSError *error) {
			[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
		}];
	}
	[self saveToGaleryEndedWithError:nil];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	return saveAnyContent ? YES : %orig;
}

%end

%hook IFNetworkService

- (instancetype)initWithNetworkClient:(IFNetworkClientImpl *)client {
	NSString *ifunnyDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *bearerToken = [[client authorizationHeader] stringByReplacingOccurrencesOfString:@"Bearer " withString:@""];
	NSString *bearerTokenPath = [NSString stringWithFormat:@"%@/%@", ifunnyDocumentsDirectory, @"ifunnierbearertoken"];
	[bearerToken writeToFile:bearerTokenPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	return %orig;
}

%end

static void loadPreferences() {
	NSDictionary *preferences = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.eamontracey.ifunnierpreferences.plist"];

	enabled = [preferences objectForKey:@"enabled"] ? [[preferences objectForKey:@"enabled"] boolValue] : YES;
	blockAds = [preferences objectForKey:@"blockAds"] ? [[preferences objectForKey:@"blockAds"] boolValue] : YES;
	removeWatermarks = [preferences objectForKey:@"removeWatermarks"] ? [[preferences objectForKey:@"removeWatermarks"] boolValue] : YES;
	saveAnyContent = [preferences objectForKey:@"saveAnyContent"] ? [[preferences objectForKey:@"saveAnyContent"] boolValue] : YES;
}

%ctor {
	loadPreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPreferences, CFSTR("com.eamontracey.ifunnierpreferences/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (enabled) {
		%init(AdvertisementAvailableServiceImpl = NSClassFromString(@"libFunny.AdvertisementAvailableServiceImpl"));
	}
}