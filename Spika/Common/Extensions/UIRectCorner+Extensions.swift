//
//  UIRectCorner+Extensions.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import UIKit
extension UIRectCorner {
    static let topCorners: UIRectCorner = [.topLeft, .topRight]
    static let bottomCorners: UIRectCorner =  [.bottomLeft, .bottomRight]
    static let allButBottomRight: UIRectCorner = [.bottomLeft, .topLeft, .topRight]
    static let allButBottomLeft: UIRectCorner = [.bottomRight, .topLeft, .topRight]
}
