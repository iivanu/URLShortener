//
//  DataModel.swift
//  URL Shortener
//
//  Created by Ivan Ivanušić on 18/10/2020.
//

import Foundation

let token = "c798d97ad43267d09a2eab588a954fc52c0f84a4"
let apiURL = URL(string: "https://api-ssl.bitly.com/v4/shorten")!

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
