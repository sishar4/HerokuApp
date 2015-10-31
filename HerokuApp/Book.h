//
//  Book.h
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

+(id)sharedInstance;

@property (nonatomic, strong) NSMutableArray *bookArray;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *lastCheckedOut;
@property (nonatomic, strong) NSString *lastCheckedOutBy;
@property (nonatomic, strong) NSString *url;

- (id)initWithTitle:(NSString *)title author:(NSString *)author publisher:(NSString *)publisher tags:(NSString *)tags lastCheckedOut:(NSString *)lastCheckedOut lastCheckedOutBy:(NSString *)lastCheckedOutBy url:(NSString *)url;

@end
