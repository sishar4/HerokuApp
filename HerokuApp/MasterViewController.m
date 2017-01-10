//
//  MasterViewController.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "MasterViewController.h"
#import "Book.h"
#import "HerokuApp-Swift.h"
#import "HerokuAlertHelper.h"

@interface MasterViewController () <AddBookProtocol>

@property dispatch_queue_t masterBooksQueue;
@property (nonatomic, strong) AddBookViewController *addBookViewController;
@end


@implementation MasterViewController

- (void)getAllBooks
{
    if (_spinner == nil) {
        [self allocateSpinner];
    }
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    
    [_dataController getAllBooksWithQueue:self.masterBooksQueue andCompletionHandler:^(NSMutableArray *result, BOOL success) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        
        if (success) {
            [self.books addObjectsFromArray:result];
            [self.tableView reloadData];
        } else {
            [HerokuAlertHelper presentAlertFromViewController:self WithTitle:@"Could Not Retrieve Books" andMessage:@"Failed to retrieve the list of books. Please try again."];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.masterBooksQueue = dispatch_queue_create("com.sahil.master", DISPATCH_QUEUE_SERIAL);
    
    _dataController = [[BookDataController alloc] init];
    self.books = [[NSMutableArray alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self getAllBooks];
}

- (IBAction)addNewBook:(id)sender
{
    [self performSegueWithIdentifier:@"addBook" sender:nil];
}

#pragma mark - DetailViewControllerProtocol

- (void)updatedBook:(Book *)obj AtIndex:(NSUInteger)index {
    
    Book *shared = [Book sharedInstance];
    [shared.bookArray replaceObjectAtIndex:index withObject:obj];
    [self.books replaceObjectAtIndex:index withObject:obj];
    [self.tableView reloadData];
}

#pragma mark - AddBookProtocol

- (void)addedWithBook:(Book *)book {
    
    Book *shared = [Book sharedInstance];
    [shared.bookArray addObject:book];
    [self.books addObject:book];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.books.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];

    Book *object = self.books[indexPath.row];
    cell.textLabel.text = object.title;
    cell.detailTextLabel.text = object.author;
    
    cell.layer.opaque = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Book *object = self.books[indexPath.row];
    _indexOfSelectedBook = indexPath.row;
    [self performSegueWithIdentifier:@"showDetail" sender:object];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteBookAtIndex:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (void)deleteBookAtIndex:(NSIndexPath *)indexPath
{
    if (_spinner == nil) {
        [self allocateSpinner];
    }
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    Book *bookToDelete = self.books[indexPath.row];
    NSLog(@"DELETING BOOK >>>> %@, AT INDEX >>>> %ld", bookToDelete.title, (long)indexPath.row);
    //Format book's url for delete service call
    NSString *bookUrl = [bookToDelete.url substringToIndex:[bookToDelete.url length] - 1];
    
    [_dataController deleteBookAtIndex:indexPath withUrl:bookUrl withQueue:self.masterBooksQueue andCompletionHandler:^(BOOL success) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        
        if (success) {
            [self.books removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [HerokuAlertHelper presentAlertFromViewController:self WithTitle:@"Could Not Delete Book" andMessage:@"Failed to delete the specified book. Please try again."];
        }
    }];
}

- (IBAction)deleteAllBooks:(id)sender
{
    if (self.books.count > 0) {
        UIAlertController *deleteAllAlert = [UIAlertController alertControllerWithTitle:@"Delete All Books" message:@"Are you sure you would like to delete all books in the library?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [deleteAllAlert addAction:dismiss];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"DELETING ALL BOOKS...");
            [self deleteAllBooksInList];
        }];
        [deleteAllAlert addAction:confirm];
        [self presentViewController:deleteAllAlert animated:YES completion:nil];
    } else {
        [HerokuAlertHelper presentAlertFromViewController:self WithTitle:@"No Books to Delete" andMessage:@"There are no books to delete in your library."];
    }
    
}

- (void)deleteAllBooksInList
{
    if (_spinner == nil) {
        [self allocateSpinner];
    }
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    //Delete all books
    [_dataController deleteAllBooksWithQueue:self.masterBooksQueue andCompletionHandler:^(BOOL success) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        
        if (success) {
            [self.books removeAllObjects];
            [self.tableView reloadData];
        } else {            
            [HerokuAlertHelper presentAlertFromViewController:self WithTitle:@"Could Not Delete All Books" andMessage:@"Failed to delete all books in the library. Please try again."];
        }
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
    
        self.detailViewController = (DetailViewController *)[segue destinationViewController];
        self.detailViewController.delegate = self;
        
        //set Book detail labels on detailViewController
        Book *obj = (Book *)sender;
        [self.detailViewController setBookTitle:obj.title];
        [self.detailViewController setAuthor:obj.author];
        [self.detailViewController setPublisher:obj.publisher];
        [self.detailViewController setTags:obj.tags];
        [self.detailViewController setLastCheckedOut:obj.lastCheckedOut];
        [self.detailViewController setLastCheckedOutBy:obj.lastCheckedOutBy];
        [self.detailViewController setUrl:obj.url];
        [self.detailViewController setIndexOfBook:_indexOfSelectedBook];
    } else if ([[segue identifier] isEqualToString:@"addBook"]) {
        
        self.addBookViewController = (AddBookViewController *)[segue destinationViewController];
        self.addBookViewController.delegate = self;
    }
}

- (void)allocateSpinner {
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.center = self.view.center;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _spinner = nil;
}

@end
