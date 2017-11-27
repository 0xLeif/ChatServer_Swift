//
//  User.swift
//  Perfect-JSON-APIPackageDescription
//
//  Created by Sabien Ambrose on 10/16/17.
//

import Foundation
import StORM
import PostgresStORM

class User: PostgresStORM {
    var handle: String
	var friends: [String]
    var room: String
    
    override init() {
        handle = "unnamed"
        room = "lobby"
        friends = []
    }
    
    init(withHandle name: String){
        handle = name
        room = "lobby"
        friends = ["a","b","c"]
	}
    
    override open func table() -> String { return "users" }
    
    override func to(_ this: StORMRow) {
        handle = this.data["handle"] as? String ?? ""
        room = this.data["room"] as? String ?? "lobby"
		friends = "\(this.data["friends"] ?? "")".split(separator: ",").flatMap{ String($0) }
    }
    
    func rows() -> [User] {
        var rows = [User]()
        for i in 0 ..< self.results.rows.count {
            let row = User()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    func asDictionary() -> [String: Any] {
        return [
            "handle": handle,
			"friends": friends,
            "room": room
        ]
    }

    static func all() throws -> [User] {
        let getObj = User()
        try getObj.findAll()
        return getObj.rows()
    }
    
    static func first() throws -> User? {
        let getObj = User()
        let cursor = StORMCursor(limit: 1, offset: 0)
        try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
        return getObj.rows().first
    }
    
    static func user(withHandle handle:String) throws -> User {
        let getObj = User()
        let findObj = ["handle": handle]
        try getObj.find(findObj)
        return getObj
    }
}

extension User: Hashable {
	var hashValue: Int {
		return handle.hashValue
	}
	static func ==(lhs: User, rhs: User) -> Bool {
		return lhs.handle == rhs.handle
	}
}
