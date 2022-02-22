//
//  BackgroundButton.swift
//  Spika
//
//  Created by Marko on 22.10.2021..
//

import UIKit

class ImageViewWithIcon: UIView, BaseView {
    
    private let backgroundView = UIView()
    private let mainImageView = UIImageView()
    private let plainImageView = UIImageView()
    private let cameraIcon = ImageButton(image: UIImage(named: "camera")!, size: CGSize(width: 28, height: 28))
    
    private let image: UIImage
    private let size: CGSize
    
    init(image: UIImage, size: CGSize = CGSize(width: 44, height: 44)) {
        self.image = image
        self.size = size
        super.init(frame: CGRect(x: .zero, y: .zero, width: size.width, height: size.height))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        addSubview(backgroundView)
        backgroundView.addSubview(plainImageView)
        backgroundView.addSubview(mainImageView)
        addSubview(cameraIcon)
    }
    
    func styleSubviews() {
        backgroundView.backgroundColor = .appBlueLight
        backgroundView.layer.cornerRadius = size.height / 2
        backgroundView.clipsToBounds = true
        
        plainImageView.image = UIImage(named: "camera")
        plainImageView.contentMode = .scaleAspectFit

        mainImageView.image = image
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.isHidden = true
        cameraIcon.isHidden = true
    }
    
    func positionSubviews() {
        backgroundView.fillSuperview()
        backgroundView.anchor(size: size)
        
        mainImageView.centerInSuperview()
        mainImageView.anchor(size: CGSize(width: size.width, height: size.height))
        
        plainImageView.centerInSuperview()
        plainImageView.anchor(size: CGSize(width: size.width * 0.4, height: size.height * 0.4))
        
        cameraIcon.anchor(bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    func deleteMainImage() {
        plainImageView.isHidden = false
        mainImageView.isHidden  = true
        cameraIcon.isHidden = true
    }
    
    func showImage(_ image: UIImage) {
        plainImageView.isHidden = true
        
        mainImageView.image = image
        mainImageView.isHidden  = false
        cameraIcon.isHidden = false
    }
}