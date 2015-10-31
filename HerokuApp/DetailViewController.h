//
//  DetailViewController.h
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookDataController.h"

@interface DetailViewController : UIViewController <NSURLSessionDelegate, UITextFieldDelegate>

@property (nonatomic, strong) BookDataController *dataCon;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIAlertAction *okAction;
@property (nonatomic, assign) NSUInteger indexOfBook;

@property (nonatomic, assign) NSString *bookTitle;
@property (nonatomic, assign) NSString *author;
@property (nonatomic, assign) NSString *publisher;
@property (nonatomic, assign) NSString *tags;
@property (nonatomic, assign) NSString *lastCheckedOut;
@property (nonatomic, assign) NSString *lastCheckedOutBy;
@property (nonatomic, assign) NSString *url;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherLabel;
@property (nonatomic, weak) IBOutlet UILabel *tagsLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastCheckedOutLabel;

@property (nonatomic, weak) IBOutlet UIButton *checkoutButton;
- (IBAction)checkoutBook:(id)sender;
- (IBAction)shareBook:(id)sender;

@end

