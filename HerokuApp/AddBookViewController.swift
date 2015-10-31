//
//  AddBookViewController.swift
//  HerokuApp
//
//  Created by Sahil Ishar on 10/16/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

import UIKit

class AddBookViewController: UIViewController, NSURLSessionDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        if !titleTextField.text!.isEmpty || !authorTextField.text!.isEmpty || !publisherTextField.text!.isEmpty || !tagsTextField.text!.isEmpty {
            
            let alert = UIAlertController(title: "Cancel Add Book?", message: "Are you sure you want to cancel adding the new book. All unsaved changes will be lost.", preferredStyle: UIAlertControllerStyle.Alert)
            let dismissActionHandler = { (action:UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: dismissActionHandler))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func submitNewBook(sender: UIButton) {
        if titleTextField.text == "" || authorTextField.text == "" || (titleTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") || (authorTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
            let alert = UIAlertController(title: "Form Incomplete", message: "You must specify a book title and author(s) to add a new book.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            print("Book title >>> " + titleTextField.text!)
            print("Book author >>> " + authorTextField.text!)
            self.addNewBook()
        }
    }
    
    func addNewBook() {
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        actInd.startAnimating()
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: NSURL(string: "http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2/books")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        let bodyData = String(format: "title=%@&author=%@&publisher=%@&categories=%@",titleTextField.text!, authorTextField.text!, publisherTextField.text!, tagsTextField.text!)
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                print(json)
                let bookTitle = json?.objectForKey("title") as! String
                let author = json?.objectForKey("author") as! String
                let url = json?.objectForKey("url") as! String
                
                let bookObj = Book(title: bookTitle, author: author, publisher: self.publisherTextField.text, tags: self.tagsTextField.text,  lastCheckedOut: "", lastCheckedOutBy: "", url: url)
                let bookShared = Book.sharedInstance()
                bookShared.bookArray!.addObject(bookObj)
                
                dispatch_async(dispatch_get_main_queue(),{
                    //Set flag for MasterViewController to update it's list of books from the backend
                    NSUserDefaults.standardUserDefaults().setObject("YES", forKey: "didChangeListOfBooks")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            } catch let error as NSError {
                print(error)
                let alert = UIAlertController(title: "Could Not Add Book", message: "Unable to add book to the library. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
        task.resume()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
