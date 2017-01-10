//
//  HerokuAlertHelper.m
//  HerokuApp
//
//  Created by Sahil Ishar on 1/10/17.
//  Copyright © 2017 Sahil Ishar. All rights reserved.
//

#import "HerokuAlertHelper.h"

@implementation HerokuAlertHelper


+(void)presentAlertFromViewController:(UIViewController *)viewController WithTitle:(NSString *)title andMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alert addAction:removeAlert];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
