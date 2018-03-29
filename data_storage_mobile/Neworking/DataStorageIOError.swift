//
//  DataStorageIOError.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 03.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation

/// Represents errors in interacting with the DataStorage API.
public enum DataStorageIOError: Error {
    
    /// Error due to invalid JSON.
    case invalidJSON(Data)
}
