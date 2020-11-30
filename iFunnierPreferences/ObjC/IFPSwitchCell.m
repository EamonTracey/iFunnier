#import "../include/IFPSwitchCell.h"

@implementation IFPSwitchCell

- (void)setControl:(UISwitch *)control {

    [control setOnTintColor:[UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:1.0]];
    [super setControl:control];

}

@end