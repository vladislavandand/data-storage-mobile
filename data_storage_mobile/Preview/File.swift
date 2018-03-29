//
//  File.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 06.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation
import QuickLook


class File: NSObject, QLPreviewItem {
    
    let document: Document
    var previewItemURL: URL?
    var previewItemTitle: String? {
        return document.name
    }

    init(document: Document, previewItemURL: URL) {
        self.document = document
        self.previewItemURL = previewItemURL
    }
    
    func delete() {
        do {
            try FileManager.default.removeItem(at: self.previewItemURL!)
        } catch {
            print("An error occured when trying to delete file:\(self.previewItemURL!) Error:\(error)")
        }
    }
}


