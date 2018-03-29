//
//  Highlight.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 21.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

struct Highlight: Codable {
    let name: [String]?
    let documentsToSearchName: [String]?

    enum CodingKeys: String, CodingKey {
        case name
        case documentsToSearchName = "documents.to_search.name"
    }
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
