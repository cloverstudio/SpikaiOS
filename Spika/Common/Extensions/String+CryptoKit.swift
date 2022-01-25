//
//  String+CryptoKit.swift
//  Spika
//
//  Created by Marko on 08.11.2021..
//

import Foundation
import CryptoKit

extension String {
    func getSHA256() -> String {
        let data = Data(self.utf8)
        let dataHashed = SHA256.hash(data: data)
        return dataHashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
