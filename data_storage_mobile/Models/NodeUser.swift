//
//  NodeUser.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 14.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

struct NodeUser: Codable {
    let id: Int?
    let name: String
}

extension NodeUser {
    init(data: Data) throws {
        self = try JSONDecoder().decode(NodeUser.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
