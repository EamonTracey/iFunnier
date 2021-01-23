#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

//--Preferences--//
BOOL enabled;
BOOL blockAds;
BOOL removeWatermarks;
BOOL saveAnyContent;
//----//

@interface FNROContent
@property NSString *url;
@end

@interface IFFeedViewController
@property FNROContent *content;
@end

@interface IFAdViewcontroller
@property IFFeedViewController *topViewController;
@end

@interface FNApplicationController
@property IFAdViewcontroller *adViewController;
@end

@interface FNActivityView
@property FNApplicationController *applicationController;
- (void)close;
- (void)ifunnier_saveActiveContent;
@end

@interface FNActivityItem
@property NSString *accessebilityId;
@end

@interface FNActivityButton
@property FNActivityItem *activityItem;
@end

@interface IFNetworkClientImpl
- (NSString *)authorizationHeader;
@end

@interface NSObject (Swift)
- (instancetype)initWithActionType:(int)type;
@end