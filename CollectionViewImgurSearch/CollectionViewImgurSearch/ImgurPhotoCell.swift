//
//  ImgurPhotoCell.swift
//  CollectionViewImgurSearch
//
//  Created by Jon Olivet on 10/31/17.
//  Copyright © 2017 Jon Olivet. All rights reserved.
//

import UIKit

class ImgurPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
        
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 10 :0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderColor = themeColor.cgColor
        isSelected = false
    }
}
