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
    var roomName: String = ""
    var roomAdmin: User
    var users: [User]
    var messages: [Message]
	
	override init() {
		roomName = "unnamed"
		roomAdmin = User()
		users = []
		messages = []
	}
	
	init(withAdmin admin: User, andRoomName name: String){
		roomName = name
		roomAdmin = User()
		users = []
		messages = []
	}
	
	// send(message) -Tag on the ID etc
	
	
	override open func table() -> String { return "rooms" }
	
	override func to(_ this: StORMRow) {
		roomAdmin = this.data["admin"] as? User ?? User()
		roomName = this.data["name"] as? String ?? ""
		messages = this.data["messages"] as? [Message] ?? []
		users = this.data["users"] as? [User] ?? []
	}
	
	func rows() -> [Room] {
		var rows = [Room]()
		for i in 0..<self.results.rows.count {
			let row = Room()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
	
	func asDictionary() -> [String: Any] {
		return [
			"name": roomName,
			"admin": roomAdmin,
			"users": users,
			"messages": messages
		]
	}
	
	static func all() throws -> [Room] {
		let getObj = Room()
		try getObj.findAll()
		return getObj.rows()
	}
	
	static func first() throws -> Room? {
		let getObj = Room()
		let cursor = StORMCursor(limit: 1, offset: 0)
		try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
		return getObj.rows().first
	}
	
	static func with(name: String) throws -> Room {
		let getObj = Room()
		let findObj = ["name": name]
		try getObj.find(findObj)
		return getObj
	}
}
