#import "../include/Springboard.h"

%hook SBApplicationIcon

- (instancetype)initWithApplication:(id)application {
    id _orig = %orig;
    if ([[_orig uniqueIdentifier] isEqualToString:@"ru.flysoft.ifunny"]) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(ifunnier_uninstall) name:@"com.eamontracey.ifunnier/uninstallifunny" object:nil];
    }
    return _orig;
}

%new
- (void)ifunnier_uninstall {
    [self setUninstalled];
    [self completeUninstall];
}

%end