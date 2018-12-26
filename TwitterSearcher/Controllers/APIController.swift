//
//  APIController.swift
//  TwitterSearcher
//
//  Created by Ruslan on 12/10/18.
//  Copyright © 2018 Ruslan Naumenko. All rights reserved.
//

import Foundation

class APIController {
    weak var delegate : APITwitterDelegate?
    
    private var token : String?
    private let consumerKey : String = "lo0j5t40X6nt8Wj3YBzg"
    private let consumerSecret : String = "39PPCILZq7aDCaA2eN8wRp6v9uIllYBaANLLtA1sPlY"
    
    init(delegate: APITwitterDelegate) {
        self.delegate = delegate
        initToken()
    }
    
    private func initToken() {
        let bearer = ((consumerKey + ":" + consumerSecret).data(using: String.Encoding.utf8))?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        guard let url = URL(string: "https://api.twitter.com/oauth2/token") else {
            print("WRONG URL")
            delegate?.displayAlert(message: "WRONG URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic " + bearer!, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            print("RESPONSE >>>>>>>>>>")
            print(response!)
            print("RESPONSE <<<<<<<<<<")
            guard let data = data, error == nil else {
                print("REQUEST FAILED >>>>>>>>>")
                print(error!)
                print("REQUEST FAILED <<<<<<<<<")
                self.delegate?.displayAlert(message: "error: \(error!)")
                return
            }
            do {
                if let dic: NSDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    print("DICTIONARY >>>>>>>>>>>>")
                    print(dic)
                    print("DICTIONARY <<<<<<<<<<<<")
                    self.token = (dic["access_token"] as? String)!
                    print("ACCESS TOKEN >>>>>>>>>")
                    print(String(describing: self.token!))
                    print("ACCESS TOKEN <<<<<<<<<")
                    self.getTweets(str: "school 42", nbr: 100)
                }
            }
            catch let jsonERR {
                print("ERROR WITH TOKEN STUFF >>>>>>>>>")
                print(jsonERR)
                print("ERROR WITH TOKEN STUFF <<<<<<<<<")
                self.delegate?.displayAlert(message: "error: \(jsonERR)")
            }
            }.resume()
    }
    
    func getTweets(str : String, nbr : Int) {
        var tweets: [Tweet] = []
        
        let q = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let mutableURLRequest = NSMutableURLRequest(url: URL(string : "https://api.twitter.com/1.1/search/tweets.json?q=\(q)&count=\(nbr)&result_type=recent")!)
        mutableURLRequest.httpMethod = "GET"
        mutableURLRequest.setValue("Bearer " +  self.token!, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: mutableURLRequest as URLRequest, completionHandler: {
            (data, response, error) in
            print("RESPONSE >>>>>>>>>>")
            print(response!)
            print("RESPONSE <<<<<<<<<<")
            guard error == nil else {
                self.delegate?.processError(error: error! as NSError)
                return
            }
            guard let _ = data else {return}
            do {
                if let dataObject: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary,
                    let arrayStatuses = dataObject["statuses"] as? [[String:AnyObject]]
                {
                    print("responseObject >>>>>>>>>>")
                    print(dataObject)
                    print("responseObject <<<<<<<<<<")
                    for status in arrayStatuses {
                        let text = status["text"] as! String
                        let user = status["user"]?["name"]  as! String
                        if let date = status["created_at"] as? String {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
                            if let date = dateFormatter.date(from: date) {
                                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                                let newDate = dateFormatter.string(from: date)
                                tweets.append(Tweet(name: user, text: text, date: newDate))
                            }
                        }
                    }
                }
                self.delegate?.processTweet(tweets: tweets)
            }
            catch _ {
                print("Disconnected")
            }
        }).resume()
    }
}
