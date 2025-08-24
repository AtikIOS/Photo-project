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
    override func prepareForReuse() {
        super.prepareForReuse()
        self.secondImageView.image = nil
    }
    
    func configure(image: UIImage?){
        if let thumImage = image {
            secondImageView.image = thumImage
        }
    }
    
    func transformToLarge(){
        UIView.animate(withDuration: 0.2){[weak self] in
            guard let self = self else{return}
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 1.3
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func transformToStandard(){
        UIView.animate(withDuration: 0.2){[weak self] in
            guard let self = self else{return}
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
            self.transform = CGAffineTransform.identity
        }
    }
}


