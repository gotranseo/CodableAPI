//
//  APIRepresentable.swift
//  Pods
//
//  Created by Jimmy McDermott on 1/25/17.
//  Copyright Slate Solutions, Inc.

import Foundation
import Alamofire

public protocol APIRequestRepresentable {
    associatedtype ResponseType: Codable
    associatedtype ErrorType: Codable
    
    typealias SuccessAPIResponse = (_ object: ResponseType?) -> Void
    typealias ErrorAPIResponse = (_ errorObject: Codable?) -> Void
    
    var method: HTTPRequestType { get set }
    
    func jsonDecoder() -> JSONDecoder
    func request(parameters: Parameters?, successHandler: @escaping SuccessAPIResponse, errorHandler: @escaping ErrorAPIResponse)
    func headers() -> Codable
    func url() -> String
}

public extension APIRequestRepresentable {
    
    typealias ErrorType = GenericError
    
    func headers() -> Codable {
        return EmptyHeaders()
    }
    
    func jsonDecoder() -> JSONDecoder {
        return JSONDecoder()
    }
    
    func request(parameters: Parameters? = nil, successHandler: @escaping SuccessAPIResponse, errorHandler: @escaping ErrorAPIResponse) {
        guard let url = URL(string: url()) else {
            errorHandler(nil)
            return
        }
        
        var requestHeaders: [String: String]!
        
        if var httpFields = headers().asDictionary() {
            if httpFields["Content-Type"] == nil {
                httpFields["Content-Type"] = "application/json"
            }
            
            requestHeaders = httpFields
        } else {
            errorHandler(DescriptiveNetworkError("Could not turn headers object into a dictionary"))
        }
        
        Alamofire.request(
            url,
            method: method.alamofireType,
            parameters: parameters?.asDictionary(),
            encoding: JSONEncoding.default,
            headers: requestHeaders).responseJSON { response in
                //each response should have a status code and a json value
                guard let statusCode = response.response?.statusCode else {
                    errorHandler(DescriptiveNetworkError("Connection may be offline"))
                    return
                }
                
                guard let jsonValue = response.result.value else {
                    //check if the status code is still 200...300, because sometimes responses will return only a status code
                    if 200...299 ~= statusCode {
                        successHandler(nil)
                    } else {
                        //return success=false because the status code was not in the acceptable range
                        errorHandler(DescriptiveNetworkError("Could not get JSON value"))
                    }
                    
                    return
                }
                
                guard let data = try? JSONSerialization.data(withJSONObject: jsonValue) else {
                    //check if the status code is still 200...300, because sometimes responses will return only a status code
                    if 200...299 ~= statusCode {
                        successHandler(nil)
                    } else {
                        //return success=false because the status code was not in the acceptable range
                        errorHandler(DescriptiveNetworkError("Could not get parse data"))
                    }
                    
                    return
                }
                
                if 200...299 ~= statusCode {
                    //success
                    successHandler(try? self.jsonDecoder().decode(ResponseType.self, from: data))
                } else {
                    //error - we need a JSONDecoder here because `ErrorResponse` does not conform to APIModel
                    if let errorTypeObject = try? JSONDecoder().decode(ErrorType.self, from: data) {
                        errorHandler(errorTypeObject)
                    } else {
                        errorHandler(DescriptiveNetworkError("Could not turn the error response into specified error type"))
                    }
                }
        }
    }
}
