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
    let dataController: BookDataController = BookDataController()
    
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
            
            HerokuAlertHelper.presentAlert(from:self, withTitle: "Form Incomplete", andMessage: "You must specify a book title and author(s) to add a new book.")
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

        let bodyData = String(format: "title=%@&author=%@&publisher=%@&categories=%@",titleTextField.text!, authorTextField.text!, publisherTextField.text!, tagsTextField.text!)
        let queue = DispatchQueue(label: "com.sahil.add")
        
        dataController.addBook(withDetails: bodyData, withQueue: queue, andCompletionHandler: {bookObj, success -> Void in
            
            actInd.stopAnimating()
            actInd.removeFromSuperview()
            
            if success {
                DispatchQueue.main.async(execute: {
                    self.delegate?.added(book: bookObj!)
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                HerokuAlertHelper.presentAlert(from:self, withTitle: "Could Not Add Book", andMessage: "Unable to add book to the library. Please try again.")
            }
        })
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
