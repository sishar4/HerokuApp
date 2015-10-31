//
//  MasterViewController.m
//  HerokuApp
//
//  Created by Sahil Ishar on 10/15/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Book.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)getAllBooks
{
    if (_spinner == nil) {
        [self allocateSpinner];
    }
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    
    [_dataController getAllBooksWithCompletionHandler:^(NSMutableArray *result, BOOL success) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        
        if (success) {
            [self.books addObjectsFromArray:result];
            [self.tableView reloadData];
        } else {
            UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Retrieve Books" message:@"Failed to retrieve the list of books. Please try again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [failAlert addAction:removeAlert];
            [self presentViewController:failAlert animated:YES completion:nil];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Check if user added or updated a book
    NSString *didChangeListOfBooks = [[NSUserDefaults standardUserDefaults] objectForKey:@"didChangeListOfBooks"];
    if ([didChangeListOfBooks isEqualToString:@"YES"]) {
        //If so, update the list by getting new list
        Book *shared = [Book sharedInstance];
        [self.books removeAllObjects];
        [self.books addObjectsFromArray:shared.bookArray];
        [self.tableView reloadData];
        //Reset flag
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"didChangeListOfBooks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _dataController = [[BookDataController alloc] init];
    self.books = [[NSMutableArray alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self getAllBooks];
}

- (IBAction)addNewBook:(id)sender
{
    [self performSegueWithIdentifier:@"addBook" sender:nil];
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
    
    [_dataController deleteBookAtIndex:indexPath WithUrl:bookUrl andCompletionHandler:^(BOOL success) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        
        if (success) {
            [self.books removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Delete Book" message:@"Failed to delete the specified book. Please try again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [failAlert addAction:removeAlert];
            [self presentViewController:failAlert animated:YES completion:nil];
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
        UIAlertController *noDeleteAllAlert = [UIAlertController alertControllerWithTitle:@"No Books to Delete" message:@"There are no books to delete in your library." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [noDeleteAllAlert addAction:cancel];
        [self presentViewController:noDeleteAllAlert animated:YES completion:nil];
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
    [_dataController deleteAllBooksWithCompletionHandler:^(BOOL success) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        
        if (success) {
            [self.books removeAllObjects];
            [self.tableView reloadData];
        } else {
            UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:@"Could Not Delete All Books" message:@"Failed to delete all books in the library. Please try again." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *removeAlert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [failAlert addAction:removeAlert];
            [self presentViewController:failAlert animated:YES completion:nil];
        }
    }];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
    
        self.detailViewController = (DetailViewController *)[segue destinationViewController];
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
