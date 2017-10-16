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
            Route(method: .get, uri: "/", handler: indexView),
            Route(method: .post, uri: "/ga", handler: addItem),
            Route(method: .post, uri: "/ga/{id}/delete", handler: deleteItem)
        ]
    }
    
    func indexView(request: HTTPRequest, response: HTTPResponse) {
        do {
            
            var values = MustacheEvaluationContext.MapType()
            values["users"] = try UserAPI.allAsDictionary()
            mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/index.mustache")
            
        } catch {
            response.setBody(string: "Error handling request: \(error)")
                .completed(status: .internalServerError)
        }
    }
    
    func addItem(request: HTTPRequest, response: HTTPResponse) {
        do {
            guard let handle = request.param(name: "handle"),
                let rooms = request.param(name: "rooms") as? [Room],
                let friends = request.param(name: "friends") as? [User] else {
                    response.completed(status: .badRequest)
                    return
            }
            
            _ = try UserAPI.newUser(withHandle: handle, rooms: rooms, friends: friends)
            response.setHeader(.location, value: "/ga")
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

