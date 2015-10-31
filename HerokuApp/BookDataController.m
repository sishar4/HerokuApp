//
//  BookDataController.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/30/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "BookDataController.h"
#import "Book.h"

@implementation BookDataController


- (void)getAllBooksWithCompletionHandler:(void (^)(NSMutableArray *, BOOL))completionHandler {
    
    NSMutableArray *listOfBooks = [[NSMutableArray alloc] init];
    
    //Create Session
    NSURLSessionConfiguration *bookSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *bookSession = [NSURLSession sessionWithConfiguration:bookSessionConfig delegate:self delegateQueue:nil];
    
    NSString *urlString = @"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2/books";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *bookRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [bookRequest setHTTPMethod:@"GET"];
    
    //Make GET Request and handle response
    NSURLSessionDataTask *bookTask =
    [bookSession dataTaskWithRequest:bookRequest
                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       
                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                       NSLog(@"RESPONSE >>>>>> %@", response);
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if (!error && httpResponse.statusCode == 200) {
                               NSError *localError;
                               NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                               NSLog(@"BOOKS >>>>>> %@", parsedObject);
                               
                               for (NSDictionary *dict in parsedObject) {
                                   
                                   Book *bookObj = [[Book alloc] initWithTitle:[dict objectForKey:@"title"]
                                                                        author:[dict objectForKey:@"author"]
                                                                     publisher:@""
                                                                          tags:@""
                                                                lastCheckedOut:@""
                                                              lastCheckedOutBy:@""
                                                                           url:[dict objectForKey:@"url"]];
                                   
                                   //Handle possible null values
                                   if ([dict objectForKey:@"publisher"] != [NSNull null]) {
                                       [bookObj setPublisher:[dict objectForKey:@"publisher"]];
                                   }
                                   if ([dict objectForKey:@"categories"] != [NSNull null]) {
                                       [bookObj setTags:[dict objectForKey:@"categories"]];
                                   }
                                   if ([dict objectForKey:@"lastCheckedOut"] != [NSNull null]) {
                                       [bookObj setLastCheckedOut:[dict objectForKey:@"lastCheckedOut"]];
                                   }
                                   if ([dict objectForKey:@"lastCheckedOutBy"] != [NSNull null]) {
                                       [bookObj setLastCheckedOutBy:[dict objectForKey:@"lastCheckedOutBy"]];
                                   }
                                   
                                   Book *shared = [Book sharedInstance];
                                   [shared.bookArray addObject:bookObj];
                                   [listOfBooks addObject:bookObj];
                               }
                               
                               completionHandler(listOfBooks, YES);
                           }
                           else {
                               //show error message
                               NSLog(@"ERROR >>>>>>> %@", error.description);
                               completionHandler(listOfBooks, NO);
                           }
                       });
                       
                   }];
    [bookTask resume];
}

- (void)deleteAllBooksWithCompletionHandler:(void (^)(BOOL))completionHandler {
    
    //Create Session
    NSURLSessionConfiguration *deleteAllBooksSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *deleteAllBooksSession = [NSURLSession sessionWithConfiguration:deleteAllBooksSessionConfig delegate:self delegateQueue:nil];
    
    NSString *urlString = @"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2/clean";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *deleteAllBooksRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [deleteAllBooksRequest setHTTPMethod:@"DELETE"];
    
    //Make DELETE Request and handle response
    NSURLSessionDataTask *deleteAllBooksTask =
    [deleteAllBooksSession dataTaskWithRequest:deleteAllBooksRequest
                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                 
                                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                 NSLog(@"RESPONSE >>>>>> %@", response);
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                     if (!error && httpResponse.statusCode == 200) {
                                         Book *shared = [Book sharedInstance];
                                         [shared.bookArray removeAllObjects];
                                         completionHandler(YES);
                                     }
                                     else {
                                         //show error message
                                         NSLog(@"ERROR >>>>>>> %@", error.description);
                                         completionHandler(NO);
                                     }
                                 });
                                 
                             }];
    [deleteAllBooksTask resume];
}

@end
