//
//  MainButtton.swift
//  Spika
//
//  Created by Nikola Barbarić on 10.11.2023..
//

import SwiftUI

struct PrimaryButton: View {
    enum Usage {
        case withCheckmark
        case withRightArrow
        case onlyTitle
        
        var imageResource: ImageResource? {
            return switch self {
            case .withCheckmark: .rDcheckmark
            case .withRightArrow: .rDrightArrow
            case .onlyTitle: nil
            }
        }
    }
    
    private let leftImageResource: ImageResource?
    private let text: String
    private var corners: UIRectCorner?
    private let backgroundColor: UIColor
    private let action: () -> ()
    private let usage: Usage
    
    init(imageResource: ImageResource? = nil, text: String, corners: UIRectCorner? = nil, backgroundColor: UIColor = .primaryColor, usage: Usage = .onlyTitle, action: @escaping ()->()) {
        self.leftImageResource = imageResource
        self.text = text
        self.corners = corners
        self.backgroundColor = backgroundColor
        self.action = action
        self.usage = usage
    }
    
    var body: some View {
        Button(action: action,
               label: {
            HStack(spacing: 0) {
                if let leftImageResource {
                    Image(leftImageResource)
                        .padding(.leading, 16)
                        .foregroundStyle(Color(uiColor: .textPrimary))
                }
                Text(text)
                    .padding(.leading, 12)
                    .foregroundStyle(Color(uiColor: .textPrimary))
                    .font(Font(UIFont.customFont(name: .MontserratSemiBold, size: 14)))
                Spacer()
                
                if let rightImageResource = usage.imageResource {
                    Image(rightImageResource)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 16)
                        .foregroundStyle(Color(uiColor: UIColor.textPrimary))
                    // TODO: -
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(uiColor: backgroundColor))
            .modifier(RoundedCorners(corners: corners, radius: 15))
        })
    }
}

#Preview {
    PrimaryButton(imageResource: .rDprivacyEye, text: "Privacy", corners: .bottomCorners, usage: .withCheckmark) {
        
    }
}