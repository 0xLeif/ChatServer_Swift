//
//  RoomAPI.swift
//  Perfect-JSON-APIPackageDescription
//
//  Created by Sabien Ambrose on 10/16/17.
//

import Foundation

class RoomAPI {
	static func toDictionary(rooms: [Room]) -> [[String: Any]] {
		return rooms.map{ $0.asDictionary() }
	}
	
	static func allAsDictionary() throws -> [[String: Any]] {
		let all = try Room.all()
		return toDictionary(rooms: all)
	}
	
	static func all() throws -> String {
		return try allAsDictionary().jsonEncodedString()
	}
	
	static func first() throws -> String {
		if let first = try Room.first() {
			return try first.asDictionary().jsonEncodedString()
		} else {
			return try [].jsonEncodedString()
		}
	}
	
	static func matchingShort(_ matchingShort: String) throws -> Room? {
		return try Room.with(name: matchingShort)
	}
	
	static func delete(name: String) throws {
		let room = try Room.with(name: name)
		try room.delete()
	}
	
	static func deleteFirst() throws -> String {
		guard let room = try Room.first() else {
			return "No item to update"
		}
		try room.delete()
		return try all()
	}
	
	static func newRoom(withName roomName: String, admin: String, users: [User] = [], messages: [Message] = []) throws -> [String: Any] {
		let room = Room(withAdmin: admin, andRoomName: roomName)
		room.users = users
		room.messages = messages
		try room.create()
		return room.asDictionary()
	}
	
	static func newRoom(withJSONRequest json: String?) throws -> String {
		guard let json = json,
			let dict = try json.jsonDecode() as? [String: Any],
			let name = dict["name"] as? String,
			let admin = dict["admin"] as? String else {
				return "Invalid Params"
		}
		
		return try newRoom(withName: name, admin: admin, users: [], messages: []).jsonEncodedString()
	}
	
	static func updateRoom(withJSONRequest json: String?) throws -> String {
		guard let json = json,
			let dict = try json.jsonDecode() as? [String: Any],
			let roomName = dict["name"] as? String,
			let admin = dict["admin"] as? User,
			let users = dict["users"] as? [User],
			let messages = dict["messages"] as? [Message] else {
				return "Invalid parameters"
		}
		let room = try Room.with(name: roomName)
		room.roomAdmin = admin.handle
		room.users = users
		room.messages = messages
		try room.save()
		
		return try room.asDictionary().jsonEncodedString()
	}
}
