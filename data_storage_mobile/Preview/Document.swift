//
//  Document.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 03.03.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import Foundation
import UIKit

struct Document: Codable {
    let id: Int
    let name: String
    let downloadURL: String?
    let typeString: String?
    var type: DocumentType {
        return DocumentType(rawValue: self.typeString!)!
    }
    
 
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case downloadURL = "url"
        case typeString = "type"
    }
    
}

extension Document {
    init(data: Data) throws {
        self = try JSONDecoder().decode(Document.self, from: data)
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

/**
 File type
 */
enum DocumentType: String {
    
    // pictures
    case GIF = "gif"
    case JPG = "jpg"
    case JPEG = "jpeg"
    case PNG = "png"
    case BMP = "bmp"
    /// docs
    case PDF = "pdf"
    case DOC = "doc"
    case DOCX = "docx"
    case CSV = "csv"
    case XLSX = "xlsx"
    //presentations
    case PPT = "ppt"
    case PPTX = "pptx"
    // JSON/PLIST
    case PLIST = "plist"
    case JSON = "json"
    // Archive file
    case ZIP = "zip"
    // audio
    case MP3 = "mp3"
    // video
    case WEBM = "webm"
    case MP4 = "mp4"
    /// Any file
    case Default = "file"
    
    public func image() -> UIImage? {
        switch self {
        case .GIF, .JPG, .JPEG, .PNG, .BMP: return #imageLiteral(resourceName: "image")
        case .PDF: return #imageLiteral(resourceName: "pdf")
        case .PPT, .PPTX: return #imageLiteral(resourceName: "ms_powerpoint")
        case .DOC, .DOCX: return #imageLiteral(resourceName: "ms_word")
        case .CSV, .XLSX: return #imageLiteral(resourceName: "ms_excel")
        case .ZIP: return #imageLiteral(resourceName: "folder")
        default: return #imageLiteral(resourceName: "file")
        }
    }
}

