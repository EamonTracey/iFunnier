@interface NSDistributedNotificationCenter: NSNotificationCenter
@end

@interface SBApplicationIcon
@property NSString *uniqueIdentifier;
- (void)setUninstalled;
- (void)completeUninstall;
@end