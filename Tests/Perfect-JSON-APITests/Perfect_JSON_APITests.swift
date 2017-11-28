import XCTest


import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgresStORM


class Perfect_JSON_APITests: XCTestCase {
	var _test_message = Message(with: "Hello World!")
	
	func startDB() {
		PostgresConnector.host = "localhost"
		PostgresConnector.username    = "root"
		PostgresConnector.password    = "root"
		PostgresConnector.database    = "ChatServer"
		PostgresConnector.port        = 5432
		
		let userSetupObj = User()
		try? userSetupObj.setup()
		
		let roomSetupObj = Room()
		try? roomSetupObj.setup()
		
		let messagesSetupObj = Message()
		try? messagesSetupObj.setup()
	}
	
	// Login / Create new user
	func testA() {
		do {
			startDB()
			let john = try UserAPI.newUser(withHandle: "John Doe")
			let test = try User.user(withHandle: "John Doe")
			
			let john_json = try john.jsonEncodedString()
			let test_json = try test.asDictionary().jsonEncodedString()
			
			XCTAssertEqual(john_json, test_json)
		} catch {
			XCTFail()
		}
	}
	// Create & Join room
	func testB() {
		do {
			let test = try User.user(withHandle: "John Doe")
			let test_room_name = "John Doe Test Room"
			try RoomAPI.newRoom(withName: test_room_name, admin: test.handle)
			let roomToJoin = try Room.with(roomName: test_room_name)
			test.room = roomToJoin.roomName
			
			try UserAPI.updateUser(withJSONRequest: test.asDictionary().jsonEncodedString())
			
			XCTAssertEqual(test_room_name, test.room)
		} catch {
			XCTFail()
		}
		
	}
	
	// Send message
	func testC() {
		do {
			let test = try User.user(withHandle: "John Doe")
			let test_room_name = "John Doe Test Room"
			let roomToSendMessage = try Room.with(roomName: test_room_name)
			
			try MessageAPI.newMessage(_test_message)
			
			XCTAssertTrue(try MessageAPI.all().contains(string: _test_message.message))
		} catch {
			XCTFail()
		}
	}
	
	// Add a Friend
	func testD() {
		do {
			let john = try User.user(withHandle: "John Doe")
			
			try UserAPI.newUser(withHandle: "Jane Doe")
			let jane = try User.user(withHandle: "Jane Doe")
			
			john.friends.append(jane.handle)
			jane.friends.append(john.handle)
			
			try john.save()
			try jane.save()
			
			XCTAssertEqual(try User.user(withHandle: "Jane Doe").friends.first!, john.handle)
			XCTAssertEqual(try User.user(withHandle: "John Doe").friends.first!, jane.handle)
		} catch {
			XCTFail()
		}
	}
	
	// Delete message
	func testE() {
		do {
			let test = try User.user(withHandle: "John Doe")
			let test_room_name = "John Doe Test Room"
			let time_stamp = _test_message.timestamp
			let roomToDeleteMessage = try Room.with(roomName: test_room_name)
			
			
			let message = try MessageAPI.matchingShort(time_stamp)
			
			try message?.delete()
			
			XCTAssertFalse(try MessageAPI.all().contains(string: _test_message.message))
		} catch {
			XCTFail()
		}
	}
	
	// Leave & Delete Room
	func testF() {
		do {
			let test = try User.user(withHandle: "John Doe")
			let test_room_name = "John Doe Test Room"
			let roomToLeave = try Room.with(roomName: test_room_name)
			test.room = "lobby"
			
			try UserAPI.updateUser(withJSONRequest: test.asDictionary().jsonEncodedString())
			
			let updated_test = try User.user(withHandle: "John Doe")
			
			XCTAssertEqual(updated_test.room, "lobby")
			
			try roomToLeave.delete()
			
			XCTAssertNotEqual(try roomToLeave.asDictionary().jsonEncodedString(), try Room.with(roomName: test_room_name).asDictionary().jsonEncodedString())
		} catch {
			XCTFail()
		}
		
	}
	// Logout & Delete User
	func testG() {
		do {
			let john = try User.user(withHandle: "John Doe")
			let jane = try User.user(withHandle: "Jane Doe")
			let john_json = try john.asDictionary().jsonEncodedString()
			let jane_json = try jane.asDictionary().jsonEncodedString()
			
			try john.delete()
			try jane.delete()
			
			let deleted_john = try User.user(withHandle: john.handle).asDictionary().jsonEncodedString()
			let deleted_jane = try User.user(withHandle: jane.handle).asDictionary().jsonEncodedString()
			XCTAssertNotEqual(deleted_john, john_json)
			XCTAssertNotEqual(deleted_jane, jane_json)
		} catch {
			XCTFail()
		}
	}
	


    static var allTests : [(String, (Perfect_JSON_APITests) -> () throws -> Void)] {
        return [
			("Login / Create new user", testA),
			("Create & Join room ", testB),
			("Send message", testC),
			("Add a Friend", testD),
			("Delete message", testE),
			("Leave & Delete Room", testF),
			("Logout & Delete User", testG)
        ]
    }
}
