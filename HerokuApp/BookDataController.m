//
//  BookDataController.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/30/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "BookDataController.h"

@implementation BookDataController

- (id)init {
    self = [super init];
    
    if (self)
    {
        NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.bookDataControllerSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:nil];
    }
    
    return self;
}

- (void)getAllBooksWithQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(NSMutableArray *, BOOL))completionHandler {
    
    __block NSMutableArray *listOfBooks = [[NSMutableArray alloc] init];
    
    dispatch_block_t getBooksBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, 0, ^{
        
        NSString *urlString = @"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2/books";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *bookRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [bookRequest setHTTPMethod:@"GET"];
        
        //Make GET Request and handle response
        NSURLSessionDataTask *bookTask =
        [self.bookDataControllerSession dataTaskWithRequest:bookRequest
                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                           
                           NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                           NSLog(@"RESPONSE >>>>>> %@", response);
                           
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

                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completionHandler(listOfBooks, YES);
                               });
                           }
                           else {
                               //show error message
                               NSLog(@"ERROR >>>>>>> %@", error.description);
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   completionHandler(listOfBooks, NO);
                               });
                           }
                       }];
        [bookTask resume];
    });
    
    dispatch_sync(dispatch_queue_t_queue, getBooksBlock);
}

- (void)deleteAllBooksWithQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(BOOL))completionHandler {
    
    dispatch_block_t deleteAllBooksBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, 0, ^{
        
        NSString *urlString = @"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2/clean";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *deleteAllBooksRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [deleteAllBooksRequest setHTTPMethod:@"DELETE"];
        
        //Make DELETE Request and handle response
        NSURLSessionDataTask *deleteAllBooksTask =
        [self.bookDataControllerSession dataTaskWithRequest:deleteAllBooksRequest
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                     
                                     NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                     NSLog(@"RESPONSE >>>>>> %@", response);
                                     
                                     if (!error && httpResponse.statusCode == 200) {
                                         Book *shared = [Book sharedInstance];
                                         [shared.bookArray removeAllObjects];
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             completionHandler(YES);
                                         });
                                     }
                                     else {
                                         //show error message
                                         NSLog(@"ERROR >>>>>>> %@", error.description);
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             completionHandler(NO);
                                         });
                                     }
                                 }];
        [deleteAllBooksTask resume];
    });
                                                                          
    dispatch_sync(dispatch_queue_t_queue, deleteAllBooksBlock);
}

- (void)deleteBookAtIndex:(NSIndexPath *)index withUrl:(NSString *)bookURL withQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(BOOL))completionHandler {
    
    dispatch_block_t deleteBookBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, 0, ^{
        
        NSString *urlString = [NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2%@", bookURL];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *deleteBookRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [deleteBookRequest setHTTPMethod:@"DELETE"];
        
        //Make DELETE Request and handle response
        NSURLSessionDataTask *deleteBookTask =
        [self.bookDataControllerSession dataTaskWithRequest:deleteBookRequest
                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                 
                                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                 NSLog(@"RESPONSE >>>>>> %@", response);
                                 
                                 if (!error && httpResponse.statusCode == 204) {
                                     Book *shared = [Book sharedInstance];
                                     [shared.bookArray removeObjectAtIndex:index.row];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         completionHandler(YES);
                                     });
                                 }
                                 else {
                                     //show error message
                                     NSLog(@"ERROR >>>>>>> %@", error.description);
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         completionHandler(NO);
                                     });
                                 }
                             }];
        [deleteBookTask resume];
    });
    
    dispatch_sync(dispatch_queue_t_queue, deleteBookBlock);
}

- (void)checkoutBookWithUrl:(NSString *)bookURL withName:(NSString *)bookName withDateString:(NSString *)dateStr withQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(Book *, BOOL))completionHandler {
    
    dispatch_block_t checkoutBookBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, 0, ^{

        NSString *urlString = [NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2%@", bookURL];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *checkoutBookRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [checkoutBookRequest setHTTPMethod:@"PUT"];
        [checkoutBookRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        
        NSMutableString *myRequestString = [NSMutableString stringWithString:@"lastCheckedOutBy="];
        [myRequestString appendString:bookName];
        [myRequestString appendString:@"&lastCheckedOut="];
        [myRequestString appendString:dateStr];
        NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
        [checkoutBookRequest setHTTPBody:requestData];
        
        //Make GET Request and handle response
        NSURLSessionDataTask *checkoutBookTask =
        [self.bookDataControllerSession dataTaskWithRequest:checkoutBookRequest
                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                   
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   NSLog(@"RESPONSE >>>>>> %@", response);
                                   
                                   if (!error && httpResponse.statusCode == 200) {
                                       NSError *localError;
                                       NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                       NSLog(@"UPDATED BOOK >>>>>> %@", parsedObject);
                                       
                                       Book *bookObj = [[Book alloc] initWithTitle:[parsedObject objectForKey:@"title"]
                                                                            author:[parsedObject objectForKey:@"author"]
                                                                         publisher:@""
                                                                              tags:@""
                                                                    lastCheckedOut:[parsedObject objectForKey:@"lastCheckedOut"]
                                                                  lastCheckedOutBy:[parsedObject objectForKey:@"lastCheckedOutBy"]
                                                                               url:[parsedObject objectForKey:@"url"]];
                                       
                                       //Handle possible null values
                                       if ([parsedObject objectForKey:@"publisher"] != [NSNull null]) {
                                           [bookObj setPublisher:[parsedObject objectForKey:@"publisher"]];
                                       }
                                       if ([parsedObject objectForKey:@"categories"] != [NSNull null]) {
                                           [bookObj setTags:[parsedObject objectForKey:@"categories"]];
                                       }
                                       if ([parsedObject objectForKey:@"lastCheckedOut"] != [NSNull null]) {
                                           [bookObj setLastCheckedOut:[parsedObject objectForKey:@"lastCheckedOut"]];
                                       }
                                       if ([parsedObject objectForKey:@"lastCheckedOutBy"] != [NSNull null]) {
                                           [bookObj setLastCheckedOutBy:[parsedObject objectForKey:@"lastCheckedOutBy"]];
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completionHandler(bookObj, YES);
                                       });
                                   }
                                   else {
                                       //show error message
                                       NSLog(@"ERROR >>>>>>> %@", error.description);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           completionHandler(nil, NO);
                                       });
                                   }
                               }];
        [checkoutBookTask resume];
    });
    
    dispatch_sync(dispatch_queue_t_queue, checkoutBookBlock);
}

- (void)addBookWithDetails:(NSString *)details withQueue:(id)dispatch_queue_t_queue andCompletionHandler:(void (^)(Book *, BOOL))completionHandler {
    
    dispatch_block_t addBookBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, 0, ^{
        
        NSString *urlString = @"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2/books";
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *addBookRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [addBookRequest setHTTPMethod:@"POST"];
        [addBookRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [addBookRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [addBookRequest setHTTPBody:[details dataUsingEncoding:NSUTF8StringEncoding]];
        
        //Make GET Request and handle response
        NSURLSessionDataTask *addBookTask =
        [self.bookDataControllerSession dataTaskWithRequest:addBookRequest
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                              NSLog(@"RESPONSE >>>>>> %@", response);
                                              
                                              if (!error && httpResponse.statusCode == 200) {
                                                  NSError *localError;
                                                  NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                                  NSLog(@"UPDATED BOOK >>>>>> %@", parsedObject);
                                                  
                                                  Book *bookObj = [[Book alloc] initWithTitle:[parsedObject objectForKey:@"title"]
                                                                                       author:[parsedObject objectForKey:@"author"]
                                                                                    publisher:@""
                                                                                         tags:@""
                                                                               lastCheckedOut:@""
                                                                             lastCheckedOutBy:@""
                                                                                          url:[parsedObject objectForKey:@"url"]];
                                                  
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      completionHandler(bookObj, YES);
                                                  });
                                              }
                                              else {
                                                  //show error message
                                                  NSLog(@"ERROR >>>>>>> %@", error.description);
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      completionHandler(nil, NO);
                                                  });
                                              }
                                          }];
        [addBookTask resume];
    });
    
    dispatch_sync(dispatch_queue_t_queue, addBookBlock);
}
@end
