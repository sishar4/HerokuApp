//
//  BookDataController.h
//  HerokuApp
//
//  Created by Sahil Ishar on 10/30/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BookDataController : NSObject <NSURLSessionDelegate>

-(void)getAllBooksWithCompletionHandler:(void (^)(NSMutableArray *result, BOOL success))completionHandler;
- (void)deleteAllBooksWithCompletionHandler:(void (^)(BOOL success))completionHandler;

@end
