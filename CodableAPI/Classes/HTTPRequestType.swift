//
//  HTTPRequestType.swift
//  Pods
//
//  Created by Jimmy McDermott on 1/25/17.
//  Copyright Slate Solutions, Inc.

import Foundation
import Alamofire

public enum HTTPRequestType {
    case get
    case post
    case delete
    case patch
    
    var alamofireType: Alamofire.HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .delete: return .delete
        case .patch: return .patch
        }
    }
}
