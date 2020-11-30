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

%hook IFAdViewController

- (void)presentViewController:(UIViewController *)controller animated:(BOOL)animated completion:(id)handler {

	if (![controller isKindOfClass:NSClassFromString(@"libFunny.LimitedAdTrackingPopupViewController")] || !blockAds) {
		%orig;
	}

}

%end

%hook IFFeedViewController

- (NSArray *)fn_activityItemActionsForContent:(id)content contentFeedType:(NSInteger *)type {

	if (!saveAnyContent) return %orig;

	NSMutableArray *newItems = [%orig mutableCopy];
	if ([[newItems[0] valueForKey:@"actionType"] intValue] != 1) { // Do not insert when already present
		id activityItemData = [[NSClassFromString(@"libFunny.ActivityItemData") alloc] initWithActionType:1]; // 1 -> Save item
		[newItems insertObject:activityItemData atIndex:0];
	}

	return newItems;

}

%end

%hook FNActivityView

- (void)onItemChoosed:(FNActivityButton *)button {

	if ([[[button activityItem] accessebilityId] isEqualToString:@"saveItem"]) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self ifunnier_saveActiveContent];
			[[[UIImpactFeedbackGenerator alloc] init] impactOccurred];
		});
		[self close];
	} else {
		%orig;
	}

}

%new
- (void)ifunnier_saveActiveContent {

	NSURL *contentURL = [NSURL URLWithString:[[[[[self applicationController] adViewController] topViewController] content] url]];
	NSString *extension = [contentURL pathExtension];
	NSData *contentData = [NSData dataWithContentsOfURL:contentURL];
	if ([extension isEqualToString:@"jpg"]) {
		UIImage *contentImage = [[UIImage alloc] initWithData:contentData];
		if (removeWatermarks) {
			CGRect cropRect = CGRectMake(0, 0, contentImage.size.width, contentImage.size.height - 20);
			CGImageRef contentImageRef = CGImageCreateWithImageInRect([contentImage CGImage], cropRect);
			UIImage *croppedContentImage = [UIImage imageWithCGImage:contentImageRef];
			CGImageRelease(contentImageRef);
			UIImageWriteToSavedPhotosAlbum(croppedContentImage, nil, nil, nil);
		} else {
			UIImageWriteToSavedPhotosAlbum(contentImage, nil, nil, nil);
		}
	} else if ([extension isEqualToString:@"gif"]) {
		[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    		[[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:contentData options:nil];
		} completionHandler:nil];
	} else {
		NSString *ifunnyDocumentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", ifunnyDocumentsDirectory, @"ifunniertmp.mp4"];
		[contentData writeToFile:tmpPath atomically:YES];
		[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:tmpPath]];
        } completionHandler:^(BOOL success, NSError *error) {
			[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
		}];
	}

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