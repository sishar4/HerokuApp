//
//  BookDataController.h
//  HerokuApp
//
//  Created by Sahil Ishar on 10/30/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookDataController : NSObject <NSURLSessionDelegate>

- (void)getAllBooksWithCompletionHandler:(void (^)(NSMutableArray *result, BOOL success))completionHandler;
- (void)deleteAllBooksWithCompletionHandler:(void (^)(BOOL success))completionHandler;
- (void)deleteBookAtIndex:(NSIndexPath *)index WithUrl:(NSString *)bookURL andCompletionHandler:(void (^)(BOOL success))completionHandler;
- (void)checkoutBookWithUrl:(NSString *)bookURL WithName:(NSString *)bookName withDateString:(NSString *)dateStr andCompletionHandler:(void (^)(Book *book, BOOL success))completionHandler;

@end
