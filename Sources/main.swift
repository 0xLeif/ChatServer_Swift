//
//  main.swift
//  Perfect JSON API Example
//
//  Created by Jonathan Guthrie on 2016-09-26.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgresStORM

PostgresConnector.host = "localhost"
PostgresConnector.username    = "root"
PostgresConnector.password    = "root"
PostgresConnector.database    = "ChatServer"
PostgresConnector.port        = 5432

let setupObj = User()
try? setupObj.setup()

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()

func JSON(message: String, response: HTTPResponse) {
    do {
        try response
            .setBody(json: ["message": message])
            .setHeader(.contentType, value: "application/json")
            .completed()
    } catch {
        response
            .setBody(string: "Error handling request: \(error)")
            .completed(status: .internalServerError)
    }
}

let main = MainController()
server.addRoutes(Routes(main.routes))

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
