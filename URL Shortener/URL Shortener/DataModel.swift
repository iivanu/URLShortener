//
//  DataModel.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 18/10/2020.
//

import Foundation

/// Add the "k" keyword before the name is an best practice from Objective-C
/// this helps to recognize the difference between a local variable and a global constant
/// works with the same efficience, but looks more readable. You can user any prefix, but always use the same.
let k_token = "c798d97ad43267d09a2eab588a954fc52c0f84a4"
let k_apiURL = URL(string: "https://api-ssl.bitly.com/v4/shorten")!

/// You don't need neither inheritance from NSObject on these models, you need only follow the Codable protocols.
/// You don't need reference vars, you gonna set a value on your model and it will be done
/// Following this sentences, you need an **Struct** instead a **Class**, is more lightfull, and works as expected.
struct ResponseDataOK: Codable {
    var created_at: String
    var id: String
    var link: String
    var long_url: String
}

struct ResponseDataNotOK: Codable {
    var message: String
    var resource: String
    var description: String
}
