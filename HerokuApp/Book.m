//
//  Book.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "Book.h"

@implementation Book

- (id)initWithTitle:(NSString *)title author:(NSString *)author publisher:(NSString *)publisher tags:(NSString *)tags lastCheckedOut:(NSString *)lastCheckedOut lastCheckedOutBy:(NSString *)lastCheckedOutBy url:(NSString *)url
{
    if (self = [super init]) {
        self.title = title;
        self.author = author;
        self.publisher = publisher;
        self.tags = tags;
        self.lastCheckedOut = lastCheckedOut;
        self.lastCheckedOutBy = lastCheckedOutBy;
        self.url = url;
    }
    
    return self;
}

@end
