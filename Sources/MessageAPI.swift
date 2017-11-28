//
//  MessageAPI.swift
//  Perfect-JSON-APIPackageDescription
//
//  Created by Sabien Ambrose on 10/16/17.
//

import Foundation

class MessageAPI {
    static func toDictionary(Messages: [Message]) -> [[String: Any]] {
        return Messages.map{ $0.asDictionary() }
    }
    
    static func allAsDictionary() throws -> [[String: Any]] {
        let all = try Message.all()
        return toDictionary(Messages: all)
    }
    
    static func all() throws -> String {
        return try allAsDictionary().jsonEncodedString()
    }
    
    static func first() throws -> String {
        if let first = try Message.first() {
            return try first.asDictionary().jsonEncodedString()
        } else {
            return try [].jsonEncodedString()
        }
    }
    
    static func matchingShort(_ matchingShort: String) throws -> Message? {
        return try Message.with(timestamp: matchingShort)
    }
    
    static func delete(timestamp: String) throws {
        let message = try Message.with(timestamp: timestamp)
        try message.delete()
    }
    
    static func deleteFirst() throws -> String {
        guard let message = try Message.first() else {
            return "No item to update"
        }
        try message.delete()
        return try all()
    }
    
    static func newMessage(withText text: String, senderHandle: String, roomName: String) throws -> [String: Any] {
        let message = Message(with: text)
        message.senderHandle = senderHandle
        message.roomName = roomName
        try message.create()
        return message.asDictionary()
    }
	
	static func newMessage(_ message: Message) throws -> Message {
		try message.create()
		return message
	}
	
    static func newMessage(withJSONRequest json: String?) throws -> String {
        guard let json = json,
            let dict = try json.jsonDecode() as? [String: Any],
            let message = dict["message"] as? String,
            let senderHandle = dict["senderhandle"] as? String,
            let roomName = dict["roomname"] as? String else {
                return "Invalid Params"
        }
        return try newMessage(withText: message, senderHandle: senderHandle, roomName: roomName).jsonEncodedString()
    }
}

