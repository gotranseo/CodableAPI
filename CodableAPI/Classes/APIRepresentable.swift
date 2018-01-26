//
//  APIRepresentable.swift
//  Pods
//
//  Created by Jimmy McDermott on 1/25/17.
//  Copyright Slate Solutions, Inc.

import Foundation

public protocol APIRequestRepresentable {
    associatedtype ResponseType: Codable
    associatedtype ErrorType: Codable
    
    typealias SuccessAPIResponse = (_ object: ResponseType?) -> Void
    typealias ErrorAPIResponse = (_ errorObject: Codable?) -> Void
    
    var method: HTTPRequestType { get set }
    
    func jsonDecoder() -> JSONDecoder
    func request(parameters: Encodable?, successHandler: @escaping SuccessAPIResponse, errorHandler: @escaping ErrorAPIResponse)
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
    
    func request(parameters: Encodable?, successHandler: @escaping SuccessAPIResponse, errorHandler: @escaping ErrorAPIResponse) {
        guard let url = URL(string: url()) else {
            errorHandler(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if var httpFields = headers().asDictionary() {
            if httpFields["Content-Type"] == nil {
                httpFields["Content-Type"] = "application/json"
            }
            
            request.allHTTPHeaderFields = httpFields
        }
        
        request.httpBody = try? JSONEncoder().encode(parameters)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorHandler(DescriptiveNetworkError("Could not cast URLResponse to HTTPURLResponse"))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard let data = data else {
                if 200...299 ~= statusCode {
                    successHandler(nil)
                } else {
                    errorHandler(DescriptiveNetworkError("Could not extract data from response"))
                }
                
                return
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
                if 200...299 ~= statusCode {
                    successHandler(nil)
                } else {
                    errorHandler(DescriptiveNetworkError("Could not cast data to JSON"))
                }
                
                return
            }
            
            if 200...299 ~= statusCode {
                successHandler(try? self.jsonDecoder().decode(ResponseType.self, from: jsonData))
            } else {
                if let customCodableError = try? self.jsonDecoder().decode(ErrorType.self, from: jsonData) {
                    errorHandler(customCodableError)
                } else {
                    errorHandler(DescriptiveNetworkError("Could not cast error to custom error type of \(type(of: ErrorType.self))"))
                }
            }
        }
        
        task.resume()
    }
}
