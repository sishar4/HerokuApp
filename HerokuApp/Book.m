//
//  Book.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "Book.h"

@implementation Book

+ (id)sharedInstance
{
    static Book *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.bookArray = [[NSMutableArray alloc] init];
    });
    
    return sharedInstance;
}

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
