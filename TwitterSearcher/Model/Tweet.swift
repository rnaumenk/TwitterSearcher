//
//  Tweet.swift
//  TwitterSearcher
//
//  Created by Ruslan on 12/10/18.
//  Copyright © 2018 Ruslan Naumenko. All rights reserved.
//

import Foundation

struct Tweet : CustomStringConvertible {
    let name : String
    let text : String
    let date : String
    
    var description: String {
        return "((\(date))\(name): \(text))"
    }
    
}
