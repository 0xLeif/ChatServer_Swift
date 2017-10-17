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
			Route(method: .get, uri: "/in", handler: loginView),
            Route(method: .get, uri: "/", handler: indexView),
            Route(method: .post, uri: "/", handler: addItem),
        ]
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
    
    func indexView(request: HTTPRequest, response: HTTPResponse) {
        do {
            
            var values = MustacheEvaluationContext.MapType()
            values["rooms"] = try RoomAPI.allAsDictionary()
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
//            _ = try RoomAPI.newRoom(withName: "Free", admin: User.user(withHandle: "leif").handle, users: [], messages: [])
            _ = try UserAPI.newUser(withHandle: handle, rooms: [], friends: [])
            response.setHeader(.location, value: "/")
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
            try UserAPI.delete(handle: handle)
            
            response.setHeader(.location, value: "/ga")
                .completed(status: .movedPermanently)
            
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
}

