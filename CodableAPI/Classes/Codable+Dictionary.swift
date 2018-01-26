//
//  Codable+Dictionary.swift
//  Pods
//
//  Created by Jimmy McDermott on 1/25/17.
//  Copyright Slate Solutions, Inc.

import Foundation

extension Encodable {
    func asDictionary() -> [String: String]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
        } catch {
            return nil
        }
    }
}
