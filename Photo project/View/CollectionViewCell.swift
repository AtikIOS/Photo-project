
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellForImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure( image: UIImage) {
        
        let originalImage = image
        let targetSize = CGSize(width: 100, height: 100)
        if let thumImage = originalImage.resized(to: targetSize) {
            cellForImage.image = thumImage
        } else {
            cellForImage.image = originalImage
        }
    }
}


