#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

// Preferences
BOOL enabled;
BOOL blockAds;
BOOL removeWatermarks;
BOOL saveAnyContent;

@interface IFFeedCell
@property NSData *contentData;
@end

@interface IFFeedViewController
@property IFFeedCell *activeCell;
@end

@interface IFAdViewcontroller
@property IFFeedViewController *topViewController;
@end

@interface FNApplicationController
@property IFAdViewcontroller *adViewController;
+ (instancetype)instance;
@end

@interface FCSaveToGalleryActivity: UIActivity
- (void)saveToGaleryEndedWithError:(NSError *)error;
@end

@interface IFNetworkClientImpl
- (NSString *)authorizationHeader;
@end