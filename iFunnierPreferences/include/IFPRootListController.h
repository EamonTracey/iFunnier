#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <AVFoundation/AVFoundation.h>
#import "iFunnierPreferences-Swift.h"

@interface IFPRootListController: PSListController
@property IFPConfettiView *confettiView;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@interface NSDistributedNotificationCenter: NSNotificationCenter
@end