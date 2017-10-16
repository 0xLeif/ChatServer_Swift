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
    var senderID: int
    var roomID: int
    var timestamp: Date
}
