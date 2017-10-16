//
//  Room.swift
//  Perfect-JSON-APIPackageDescription
//
//  Created by Sabien Ambrose on 10/16/17.
//

import Foundation
import StORM
import PostgresStORM

class Room: PostgresStORM {
    var roomName: String
    var roomAdmin: User
    var users: [User]
    var messages: [Message]
    
    
}
