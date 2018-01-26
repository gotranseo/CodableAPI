//
//  DescriptiveNetworkError.swift
//  Pods
//
//  Created by Jimmy McDermott on 1/25/18.
//  Copyright Slate Solutions, Inc.

import Foundation

public final class DescriptiveNetworkError: Codable {
    let failureReason: String
    
    init(_ failureReason: String) {
        self.failureReason = failureReason
    }
}
