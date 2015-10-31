//
//  RoundedTextField.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/17/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "RoundedTextField.h"

@implementation RoundedTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 8.0;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor grayColor].CGColor;
    }
    
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

@end
