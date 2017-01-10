//
//  HerokuAlertHelper.h
//  HerokuApp
//
//  Created by Sahil Ishar on 1/10/17.
//  Copyright © 2017 Sahil Ishar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HerokuAlertHelper : NSObject

+(void)presentAlertFromViewController:(UIViewController *)viewController WithTitle:(NSString *)title andMessage:(NSString *)message;

@end
