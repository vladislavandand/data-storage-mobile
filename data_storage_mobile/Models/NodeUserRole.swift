//
//  NodeUserRole.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 03.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

enum Role: String, Codable {
    case read
    case write
    case manage
    
    func segmentedControlValue() -> Int {
        switch self {
        case .read:
            return 0
        case .write:
            return 1
        case .manage:
            return 2
        }
    }
    
    func localized() -> String {
        switch self {
        case .read:
            return "Чтение"
        case .write:
            return "Запись"
        case .manage:
            return "Редактирование"
        }
    }
}

struct NodeUserRole: Codable {
    
    let id: Int?
    var role: Role
    let mayDestroy: Bool?
    let user: NodeUser

    enum CodingKeys: String, CodingKey {
        case id
        case mayDestroy = "may_destroy"
        case role
        case user
    }
    
}


extension NodeUserRole {
    init(data: Data) throws {
        self = try JSONDecoder().decode(NodeUserRole.self, from: data)
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


