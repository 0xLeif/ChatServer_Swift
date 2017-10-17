//
//  Message.swift
//  Perfect-JSON-APIPackageDescription
//
//  Created by Sabien Ambrose on 10/16/17.
//

import Foundation
import StORM
import PostgresStORM

class Message: PostgresStORM {
    var message: String
    var senderID: String
    var roomID: Int
    let timestamp: Date = Date()
    
    override init() {
        message = ""
        senderID = ""
        roomID = 0
    }
}
