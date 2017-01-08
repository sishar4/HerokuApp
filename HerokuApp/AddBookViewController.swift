//
//  AddBookViewController.swift
//  HerokuApp
//
//  Created by Sahil Ishar on 10/16/15.
//  Copyright © 2015 Sahil Ishar. All rights reserved.
//

import UIKit

@objc protocol AddBookProtocol: class {
    
    func added(book: Book)
}

class AddBookViewController: UIViewController, URLSessionDelegate, UITextFieldDelegate {

    var delegate: AddBookProtocol?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var publisherTextField: UITextField!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if !titleTextField.text!.isEmpty || !authorTextField.text!.isEmpty || !publisherTextField.text!.isEmpty || !tagsTextField.text!.isEmpty {
            
            let alert = UIAlertController(title: "Cancel Add Book?", message: "Are you sure you want to cancel adding the new book. All unsaved changes will be lost.", preferredStyle: UIAlertControllerStyle.alert)
            let dismissActionHandler = { (action:UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: dismissActionHandler))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func submitNewBook(_ sender: UIButton) {
        if titleTextField.text == "" || authorTextField.text == "" || (titleTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces) == "") || (authorTextField.text!.trimmingCharacters(in: CharacterSet.whitespaces) == "") {
            let alert = UIAlertController(title: "Form Incomplete", message: "You must specify a book title and author(s) to add a new book.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            print("Book title >>> " + titleTextField.text!)
            print("Book author >>> " + authorTextField.text!)
            self.addNewBook()
        }
    }
    
    func addNewBook() {
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(actInd)
        actInd.startAnimating()
        
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: URL(string: "http://prolific-interview.herokuapp.com/561bdb9712514500090e71b2/books")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        let bodyData = String(format: "title=%@&author=%@&publisher=%@&categories=%@",titleTextField.text!, authorTextField.text!, publisherTextField.text!, tagsTextField.text!)
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("Body: \(strData)")
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? NSDictionary
                print(json!)
                let bookTitle = json?.object(forKey: "title") as! String
                let author = json?.object(forKey: "author") as! String
                let url = json?.object(forKey: "url") as! String
                
                let bookObj = Book(title: bookTitle, author: author, publisher: self.publisherTextField.text, tags: self.tagsTextField.text,  lastCheckedOut: "", lastCheckedOutBy: "", url: url)
                
                DispatchQueue.main.async(execute: {
                    self.delegate?.added(book: bookObj!)
                    self.dismiss(animated: true, completion: nil)
                })
                
            } catch let error as NSError {
                print(error)
                let alert = UIAlertController(title: "Could Not Add Book", message: "Unable to add book to the library. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
        task.resume()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
