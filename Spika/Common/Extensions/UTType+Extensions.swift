//
//  UTType+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 23.08.2022..
//

import UniformTypeIdentifiers
import UIKit

extension UTType {
    func thumbnail() -> UIImage {
        switch self {
        case .pdf:
            return .pdfThumbnail
        default:
            return .unknownFileThumbnail
        }
    }
}
