//
//  Node.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 03.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation
import UIKit

typealias Nodes = [Node]

enum NodeType: String, Codable {
    case folder
    case document
    
    func image() -> UIImage {
        switch self {
        case .folder:
            return #imageLiteral(resourceName: "folder")
        case .document:
            return #imageLiteral(resourceName: "file")
        }
    }
    
    func segmentedControlValue() -> Int {
        switch self {
        case .document:
            return 0
        case .folder:
            return 1
        }
    }
}

struct Node: Codable {
    
    var id: Int?
    let uuid: String?
    let parentID: Int?
    var type: NodeType?
    //let nodeSubtypeID: JSONNull?
    //let nodeSubtypeName: JSONNull?
    var name: String
    let role: Role?
    let share: Bool
    let creatorID: Int
    let creator: String?
    let createdAt: String?
    let updatedAt: String?
    let parentSystemAttr: JSONAny?
    let attributes: [String: String]?
    let parentPath: [String]?
    let documents: [Document]?
    let nodeUserRoles: [NodeUserRole]?
    let nodeMailingListRoles: [NodeMailingListRole]?
    let childNodes: [Node]?
    let parentsHash: [ParentsHash]?
    let highlight: Highlight?
    let tab: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case parentID = "parent_id"
        case type = "node_type"
        //case nodeSubtypeID = "node_subtype_id"
        //case nodeSubtypeName = "node_subtype_name"
        case name
        case role
        case share
        case creatorID = "creator_id"
        case creator
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case parentSystemAttr = "parent_system_attr"
        case attributes = "attr"
        case parentPath = "parent_path"
        case documents
        case nodeUserRoles = "node_user_roles"
        case nodeMailingListRoles = "node_mailing_list_roles"
        case childNodes
        case parentsHash = "parents_hash"
        case highlight
        case tab
    }
}

// MARK: Convenience initializers

extension Node {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Node.self, from: data)
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
