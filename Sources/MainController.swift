//
//  MainController.swift
//  TechExPackageDescription
//
//  Created by Zach Eriksen on 9/13/17.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import PerfectWebSockets

final class MainController {
    let documentRoot = "./webroot"
    
    var routes: [Route] {
        return [
            Route(method: .get, uri: "/rooms/{room}/handle/{handle}", handler: indexView),
            Route(method: .get, uri: "/login", handler: redirectView),
            Route(method: .post, uri: "/rooms/{room}/handle/{handle}", handler: indexView),
            Route(method: .post, uri: "/login", handler: addItem),
            Route(method: .get, uri: "/home/handle/{handle}", handler: indexView),
			Route(method: .get, uri:"/chat", handler: chatHandler),
			Route(method: .post, uri: "/addroom", handler: addRoom)
        ]
    }
	
	func chatHandler(request: HTTPRequest, response: HTTPResponse) {
		// Provide your closure which will return the service handler.
			WebSocketHandler(handlerProducer: {
				(request: HTTPRequest, protocols: [String]) -> WebSocketSessionHandler? in
				
				// Check to make sure the client is requesting our "echo" service.
				guard protocols.contains("chat") else {
					return nil
				}
				
				// Return our service handler.
				return ChatHandler()
			}).handleRequest(request: request, response: response)
	}
	
	func redirectView(request: HTTPRequest, response: HTTPResponse) {
        mustacheRequest(request: request, response: response, handler: MustacheHelper(values: [:]), templatePath: request.documentRoot + "/signinup.mustache")
    }
	
	func loginView(request: HTTPRequest, response: HTTPResponse) {
		do {
            var values = MustacheEvaluationContext.MapType()
			values["rooms"] = try RoomAPI.allAsDictionary()
			mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/signinup.mustache")

		} catch {
			response.setBody(string: "Error handling request: \(error)")
				.completed(status: .internalServerError)
		}
	}
    
    func sendMessageView(request: HTTPRequest, response: HTTPResponse) {
        
        
    }
    
    func indexView(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let handle = String(request.urlVariables["handle"]!) else {
                response.completed(status: .badRequest)
                return
            }
            var values = MustacheEvaluationContext.MapType()
            values["rooms"] = try RoomAPI.allAsDictionary()
            values["handle"] = handle
			print("VALUES: \(values["rooms"])")
			print("name: \(request.urlVariables["room"])")
			
			print("other name: \(request.urlVariables["roomname"])")
            if let roomName = request.urlVariables["room"] {
                values["roomname"] = roomName
				print("RN: \(roomName)")
                if let messageSent = request.param(name: "message") {
                    _ = try MessageAPI.newMessage(withText: messageSent, senderHandle: handle, roomName: roomName)
                }
                
                values["messages"] = try MessageAPI.allAsDictionary().filter{ $0["roomname"] as? String ?? "" == roomName }
            }
            
            mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/chathome.mustache")
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
	
	func addRoom(request: HTTPRequest, response: HTTPResponse) {
		do {
			guard let handle = request.param(name: "handle"),
					let roomname = request.param(name: "roomname") else {
						print("Could not find params requested")
				response.completed(status: .badRequest)
				return
			}
			_ = try RoomAPI.newRoom(withName: roomname, admin: User.user(withHandle: handle).handle, users: [], messages: [])
			response.setHeader(.location, value: "/rooms/\(roomname)/handle/\(handle)")
				.completed(status: .movedPermanently)
		} catch {
			response.setBody(string: "Error handling request: \(error)")
				.completed(status: .internalServerError)
		}
	}
    
    func addItem(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let handle = request.param(name: "handle") else {
                    response.completed(status: .badRequest)
                    return
            }
//            _ = try RoomAPI.newRoom(withName: handle, admin: User.user(withHandle: "leif").handle, users: [], messages: [])
            _ = try UserAPI.newUser(withHandle: handle, rooms: [], friends: [])
            response.setHeader(.location, value: "/home/handle/\(handle)")
                .completed(status: .movedPermanently)
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func deleteItem(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let handle = String(request.urlVariables["handle"]!) else {
                response.completed(status: .badRequest)
                return
            }
            
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
}

