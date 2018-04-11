//
//  RequestMetadata.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 03.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

/// Metadata about the consumption of the Dark Sky API.
public struct RequestMetadata {
    
    /// `Cache-Control` HTTP header for responses from the Dark Sky API.
    public let cacheControl: String?
    
    /// Server-side response time of the current request in milliseconds.
    public let responseTime: Float?
    
    public init(fromHTTPHeaderFields headerFields: [AnyHashable: Any]) {
        cacheControl = headerFields["Cache-Control"] as? String
        if var responseTimeHeader = headerFields["X-Response-Time"] as? String {
            // Remove "ms" units from the string
            responseTimeHeader = responseTimeHeader.trimmingCharacters(in: CharacterSet.letters)
            responseTime = Float(responseTimeHeader)
        } else {
            responseTime = nil
        }
    }
}
