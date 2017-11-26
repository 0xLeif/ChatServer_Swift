//
//  ChatService.swift
//  Perfect-JSON-API
//
//  Created by Zach Eriksen on 11/25/17.
//
import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectWebSockets

class ChatService {
	static let instance = ChatService()
	
	private var chats = [User: WebSocket]()
	
	func join(user: User, socket: WebSocket) {
		chats[user] = socket
		sendMessage("\(user.handle) Joined", fromUser: nil)
	}
	
	func leave(user: User) {
		chats.removeValue(forKey: user)
		sendMessage("\(user.handle) Left", fromUser: nil)
	}
	
	func sendMessage(_ message: String, fromUser user: User?) {
		guard let user = user else {
			return sendMessage(message, fromUser: User(withHandle: "Server"))
		}
		let json = ["user": user.handle, "message": "\(user.handle): \(message)"]
		
		do {
			let final = try json.jsonEncodedString()
			for (username, socket) in chats {
				if username != user {
					socket.sendStringMessage(string: final, final: true) {
						print("message: \(final) was sent by user: \(user.handle)")
					}
				}
			}
		} catch {
			print("Failed to send message")
		}
		
	}
}

class ChatHandler: WebSocketSessionHandler {
	var user: User? = nil
	
	// The name of the super-protocol we implement.
	// This is optional, but it should match whatever the client-side WebSocket is initialized with.
	let socketProtocol: String? = "chat"
	
	// This function is called by the WebSocketHandler once the connection has been established.
	func handleSession(request: HTTPRequest, socket: WebSocket) {
		print("GOOOOO")
		// Read a message from the client as a String.
		// Alternatively we could call `WebSocket.readBytesMessage` to get the data as a String.
		socket.readStringMessage {
			// This callback is provided:
			//  the received data
			//  the message's op-code
			//  a boolean indicating if the message is complete
			// (as opposed to fragmented)
			string, op, fin in
			print("hiiii")
			// The data parameter might be nil here if either a timeout
			// or a network error, such as the client disconnecting, occurred.
			// By default there is no timeout.
			guard let string = string else {
				// This block will be executed if, for example, the browser window is closed.
				if let chatUser = self.user {
					print("socket closed for \(chatUser.handle)")
					ChatService.instance.leave(user: chatUser)
				}
				
				socket.close()
				return
			}
			
			// Print some information to the console for to show the incoming messages.
			print("Read msg: \(string) op: \(op) fin: \(fin)")
			
			do {
				guard fin == true, let json = try string.jsonDecode() as? [String: Any] else {return}
				self.user = try User(withHandle: json["handle"] as! String)
				
				if let chatUser = self.user {
					if let message = json["message"] as? String {
						//If there's a message attached, we send it
						ChatService.instance.sendMessage(message, fromUser: chatUser)
					} else {
						print("Join user")
						//Otherwise, they must be joining, so add them!
						ChatService.instance.join(user: chatUser, socket: socket)
					}
				}
				
				
			} catch {
				print("Failed to decode JSON from Received Socket Message")
			}
			
			//Done working on this message? Loop back around and read the next message.
			self.handleSession(request: request, socket: socket)
		}
	}
}
