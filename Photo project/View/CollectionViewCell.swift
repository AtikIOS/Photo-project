
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellForImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellForImage.image = nil
    }
    
    func configure(image: UIImage?) {
        if let thumImage = image {
            cellForImage.image = thumImage
        }
    }
}


