# HerokuApp

App allows users to view books in the library, add a book, delete a book, or delete all books. User can also share
a book to Facebook or Twitter, and check out a book.

There are 3 screens to this app:

1) Home 
  - Lists all books in UITableView
  - Add ('+') bar button item in top left presents AddBookViewController
  - Trash bar button item in top right calls web service that deletes all books in the list
  - Swipe left on a table row, and press delete button to call web service to delete that book only
  - Selecting a row pushes book DetailViewController

2) Book Detail View
  - Shows book details
  - Share bar button item in top right bring up ActivityViewController with option to share book natively through the app
  - Checkout button calls web service to update book info by passing in the user's name to check out the book

3) Add Book View (written in Swift 2.0)
  -Fill in the textfields (title and author mandatory) and click submit button to call web service that adds book to library
  
There are 5 web service calls in total, all handled using native NSURLSession class. After updating or adding book, a flag of 
sorts is set using NSUserDefaults and the home screen checks the flag in viewWillAppear to see if it needs to update its list of
books. The updated book or newly added book is added to/updated in a Singleton object that holds the array of books, and it is taken from the server response after adding or updating the book. NSUserDefaults was used since I feel it is a cleaner and more lightweight approach as opposed to NSNotication or Protocols to accomplish this.
