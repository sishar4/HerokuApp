//
//  RoundedButton.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "RoundedButton.h"

@implementation RoundedButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 8.0;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    return self;
}

@end
