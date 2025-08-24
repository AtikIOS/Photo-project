//
//  DisplayVCfirstCell.swift
//  Photo project
//
//  Created by Atik Hasan on 8/16/24.
//

import UIKit

class DisplayVCfirstCell: UICollectionViewCell {

    @IBOutlet weak var firstImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.firstImageView.image = nil
    }

}
