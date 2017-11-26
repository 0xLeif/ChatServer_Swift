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
    var timestamp: String = Date().timeIntervalSince1970.description
    var message: String
    var senderHandle: String
    var roomName: String
    
    override init() {
        message = ""
        senderHandle = ""
        roomName = ""
    }
    
    init(with m: String){
        message = m
        senderHandle = ""
        roomName = ""
    }
    
    override open func table() -> String { return "messages" }
    
    override func to(_ this: StORMRow) {
        timestamp = this.data["timestamp"] as? String ?? ""
        message = this.data["message"] as? String ?? ""
        senderHandle = this.data["senderhandle"] as? String ?? ""
        roomName = this.data["roomname"] as? String ?? ""
    }
    
    func rows() -> [Message] {
        var rows = [Message]()
        for i in 0..<self.results.rows.count {
            let row = Message()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        return [
            "timestamp": timestamp,
            "message": message,
            "senderhandle": senderHandle,
            "roomname": roomName,
        ]
    }
    
    static func all() throws -> [Message] {
        let getObj = Message()
        try getObj.findAll()
        return getObj.rows()
    }
    
    static func first() throws -> Message? {
        let getObj = Message()
        let cursor = StORMCursor(limit: 1, offset: 0)
        try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
        return getObj.rows().first
    }
    
    static func with(timestamp: String) throws -> Message {
        let getObj = Message()
        let findObj = ["timestamp": timestamp]
        try getObj.find(findObj)
        return getObj
    }
    
}
