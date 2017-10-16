//
//  MustacheHelper.swift
//  TechExPackageDescription
//
//  Created by Zach Eriksen on 10/14/17.
//

import Foundation
import PerfectMustache

struct MustacheHelper: MustachePageHandler {
    
    var values: MustacheEvaluationContext.MapType
    
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        contxt.extendValues(with: values)
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.appendBody(string: "\(error)")
                .completed(status: .internalServerError)
        }
    }
    
}

