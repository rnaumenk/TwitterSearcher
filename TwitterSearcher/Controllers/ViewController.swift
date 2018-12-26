//
//  ViewController.swift
//  TwitterSearcher
//
//  Created by Ruslan on 12/10/18.
//  Copyright © 2018 Ruslan Naumenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, APITwitterDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UITextField!
    
    private var apiController : APIController?
    private var tweets : [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        apiController = APIController(delegate: self)
    }
    
    func processTweet(tweets : [Tweet]) {
        self.tweets = tweets
        for tweet in tweets {
            print(tweet)
        }
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func processError(error : NSError) {
        print("error: \(error)")
        displayAlert(message: "error: \(error)")
        
    }
    
    func displayAlert(message: String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }
        } ))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let search: String = textField.text!
        self.apiController?.getTweets(str: search, nbr: 100)
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.nameLabel.text = self.tweets[indexPath.row].name
        cell.dateLabel.text = self.tweets[indexPath.row].date
        cell.descLabel.text = self.tweets[indexPath.row].text
        return cell
    }
}
