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
    
    //Create Session
    NSURLSessionConfiguration *checkoutBookSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *checkoutBookSession = [NSURLSession sessionWithConfiguration:checkoutBookSessionConfig delegate:self delegateQueue:nil];
    
    //Format book's url for checkout service call
    NSString *bookUrl = [_url substringToIndex:[_url length] - 1];
    NSString *urlString = [NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2%@", bookUrl];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *checkoutBookRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [checkoutBookRequest setHTTPMethod:@"PUT"];
    [checkoutBookRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    NSDate *now = [NSDate date];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *date = [_dateFormatter stringFromDate:now];
    
    NSMutableString *myRequestString = [NSMutableString stringWithString:@"lastCheckedOutBy="];
    [myRequestString appendString:name];
    [myRequestString appendString:@"&lastCheckedOut="];
    [myRequestString appendString:date];
    NSData *requestData = [NSData dataWithBytes:[myRequestString UTF8String] length:[myRequestString length]];
    [checkoutBookRequest setHTTPBody:requestData];
    
    //Make GET Request and handle response
    NSURLSessionDataTask *checkoutBookTask =
    [checkoutBookSession dataTaskWithRequest:checkoutBookRequest
                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               NSLog(@"RESPONSE >>>>>> %@", response);
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [spinner stopAnimating];
                                   [spinner removeFromSuperview];
                                   
                                   if (!error && httpResponse.statusCode == 200) {
                                       NSError *localError;
                                       NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                                       NSLog(@"UPDATED BOOK >>>>>> %@", parsedObject);
                                       
                                       Book *bookObj = [[Book alloc] initWithTitle:[parsedObject objectForKey:@"title"]
                                                                            author:[parsedObject objectForKey:@"author"]
                                                                         publisher:self.publisherLabel.text
                                                                              tags:self.tagsLabel.text
                                                                    lastCheckedOut:[parsedObject objectForKey:@"lastCheckedOut"]
                                                                  lastCheckedOutBy:[parsedObject objectForKey:@"lastCheckedOutBy"]
                                                                               url:[parsedObject objectForKey:@"url"]];

                                       Book *shared = [Book sharedInstance];
                                       [shared.bookArray replaceObjectAtIndex:_indexOfBook withObject:bookObj];
                                       
                                       //Set flag for MasterViewController to update it's list of books
                                       [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"didChangeListOfBooks"];
                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                       [self.navigationController popViewControllerAnimated:YES];
                                       
                                   }
                                   else {
                                       //show error message
                                       NSLog(@"ERROR >>>>>>> %@", error.description);
                                       UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Checkout Book" message:@"Failed to checkout the selected book. Please try again." preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                                       [failAlert addAction:removeAlert];
                                       [self presentViewController:failAlert animated:YES completion:nil];
                                   }
                               });
                               
                           }];
    [checkoutBookTask resume];
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
