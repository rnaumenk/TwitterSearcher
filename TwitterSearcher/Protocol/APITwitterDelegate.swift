//
//  APITwitterDelegate.swift
//  TwitterSearcher
//
//  Created by Ruslan on 12/10/18.
//  Copyright © 2018 Ruslan Naumenko. All rights reserved.
//

import Foundation

protocol APITwitterDelegate : NSObjectProtocol {
    func processTweet(tweets: [Tweet])
    func processError(error: NSError)
    func displayAlert(message: String)
}
