//
//  Double+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 08.06.2023..
//

import Foundation

extension Double {
    var roundedInt64: Int64 {
        Int64(self.rounded())
    }
}
