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

@property (nonatomic, strong) NSURLSession *bookDataControllerSession;

- (void)getAllBooksWithQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(NSMutableArray *result, BOOL success))completionHandler;
- (void)deleteAllBooksWithQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(BOOL success))completionHandler;
- (void)deleteBookAtIndex:(NSIndexPath *)index withUrl:(NSString *)bookURL withQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(BOOL success))completionHandler;
- (void)checkoutBookWithUrl:(NSString *)bookURL withName:(NSString *)bookName withDateString:(NSString *)dateStr WithQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(Book *book, BOOL success))completionHandler;

@end
