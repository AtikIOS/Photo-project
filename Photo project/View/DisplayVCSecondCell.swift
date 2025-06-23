//
//  DisplayVCSecondCell.swift
//  Photo project
//
//  Created by Atik Hasan on 8/17/24.
//

import UIKit

class DisplayVCSecondCell: UICollectionViewCell {

    @IBOutlet weak var secondImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func configure(image: UIImage)
    {
        let originalImage = image
        let targetSize = CGSize(width: 100, height: 100)
        if let thumImage = originalImage.resized(to: targetSize) {
            secondImageView.image = thumImage
        } else {
            secondImageView.image = originalImage
        }

    }
    
    func transformToLarge(){
        UIView.animate(withDuration: 0.1){
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 1.3
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func transformToStandard(){
        UIView.animate(withDuration: 0.1){
            self.layer.borderWidth = 0
            self.transform = CGAffineTransform.identity
        }
    }
}


