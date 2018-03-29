//
//  ParentHash.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 21.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

struct ParentsHash: Codable {
    let id: Int
    let name: String
    let userIDS: [Int]?
    let creatorID: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case userIDS = "user_ids"
        case creatorID = "creator_id"
    }
}
