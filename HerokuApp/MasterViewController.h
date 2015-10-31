//
//  MasterViewController.h
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookDataController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSURLSessionDelegate>

@property (nonatomic, strong) BookDataController *dataController;
@property (nonatomic, strong) DetailViewController *detailViewController;
@property (nonatomic, strong) NSMutableArray *books;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) NSUInteger indexOfSelectedBook;

- (IBAction)addNewBook:(id)sender;
- (IBAction)deleteAllBooks:(id)sender;
- (void)deleteBookAtIndex:(NSIndexPath *)indexPath;

@end

