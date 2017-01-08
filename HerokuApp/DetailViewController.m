//
//  DetailViewController.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "DetailViewController.h"
#import "Book.h"

@interface DetailViewController ()

@property dispatch_queue_t detailBookQueue;
@end

@implementation DetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    [self.titleLabel setText:_bookTitle];
    [self.authorLabel setText:_author];
    [self.publisherLabel setText:_publisher];
    [self.tagsLabel setText:_tags];
    if (![_lastCheckedOut isEqualToString:@""] && ![_lastCheckedOutBy isEqualToString:@""]) {
        [self.lastCheckedOutLabel setText:[NSString stringWithFormat:@"%@ @ %@", _lastCheckedOutBy, [self configureCheckoutDateWithDateString:_lastCheckedOut]]];
    } else {
        [self.lastCheckedOutLabel setText:@""];
    }
}

- (NSString *)configureCheckoutDateWithDateString:(NSString *)dateStr
{
    NSString *finalCheckoutDate;
    
    //Convert passed in string to date
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *passedInDate = [_dateFormatter dateFromString:dateStr];
    
    //Create new string with date formatted to update to local time zone
    [_dateFormatter setDateFormat:@"MMMM d, YYYY hh:mm a"];
    _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    finalCheckoutDate = [_dateFormatter stringFromDate:passedInDate];
    
    return finalCheckoutDate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.detailBookQueue = dispatch_queue_create("com.sahil.checkout", DISPATCH_QUEUE_SERIAL);
    _dataCon = [[BookDataController alloc] init];
}

- (IBAction)checkoutBook:(id)sender
{
    UIAlertController *nameAlert = [UIAlertController alertControllerWithTitle:@"Your Name" message:@"Enter your name to check out this book." preferredStyle:UIAlertControllerStyleAlert];
    [nameAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.delegate = self;
        [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventAllEditingEvents];
    }];
    
    _okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = nameAlert.textFields[0];
        [self checkoutBookWithName:textField.text];
    }];
    _okAction.enabled = NO;
    [nameAlert addAction: _okAction];
    [nameAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:nameAlert animated:YES completion:nil];
}

- (void)checkoutBookWithName:(NSString *)name
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    //Format book's url for checkout service call
    NSString *bookUrl = [_url substringToIndex:[_url length] - 1];
    //Format date
    NSDate *now = [NSDate date];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *date = [_dateFormatter stringFromDate:now];
    
    [_dataCon checkoutBookWithUrl:bookUrl withName:name withDateString:date WithQueue:self.detailBookQueue andCompletionHandler:^(Book *bookObj, BOOL success) {
        
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        
        if (success) {
            [bookObj setPublisher:self.publisherLabel.text];
            [bookObj setTags:self.tagsLabel.text];
            Book *shared = [Book sharedInstance];
            [shared.bookArray replaceObjectAtIndex:_indexOfBook withObject:bookObj];
            
            //Set flag for MasterViewController to update it's list of books
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"didChangeListOfBooks"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Checkout Book" message:@"Failed to checkout the selected book. Please try again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [failAlert addAction:removeAlert];
            [self presentViewController:failAlert animated:YES completion:nil];
        }
    }];
}

- (IBAction)shareBook:(id)sender
{
    NSMutableArray *packet = [[NSMutableArray alloc] initWithObjects:self.titleLabel.text, [NSString stringWithFormat:@"By %@", self.authorLabel.text], nil];
    if (![self.publisherLabel.text isEqualToString:@""]) {
        [packet addObject:[NSString stringWithFormat:@"Publisher: %@", self.publisherLabel.text]];
    }
    if (![self.tagsLabel.text isEqualToString:@""]) {
        [packet addObject:[NSString stringWithFormat:@"Categories: %@", self.tagsLabel.text]];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:packet applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]){
        return YES;
    }
    else {
        NSCharacterSet *blockedCharacters = [[NSCharacterSet letterCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
    }
}

- (void)textChanged:(UITextField *)textField
{
    if(![[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] && textField.text.length > 0)
    {
        _okAction.enabled = YES;
    } else {
        _okAction.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _dateFormatter = nil;
    _okAction = nil;
}

@end
