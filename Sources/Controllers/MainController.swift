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

final class MainController {
    let documentRoot = "./webroot"
    
    var routes: [Route] {
        return [
            Route(method: .get, uri: "/rooms/{room}/handle/{handle}", handler: indexView),
            Route(method: .get, uri: "/login", handler: redirectView),
            Route(method: .post, uri: "/rooms/{room}/handle/{handle}", handler: indexView),
            Route(method: .post, uri: "/login", handler: addItem),
            Route(method: .get, uri: "/home/handle/{handle}", handler: indexView),
        ]
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
            if let roomName = request.urlVariables["room"] {
                values["roomname"] = roomName
                
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

