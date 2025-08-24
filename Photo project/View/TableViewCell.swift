
import UIKit

protocol TableViewCellDelegate: AnyObject {
    func addImageButtonTapped(in cell: TableViewCell)
    func imageTapped(in cell: TableViewCell, at index: IndexPath, name: String)
}


class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var myImageCollectionview: UICollectionView! {
        didSet {
            myImageCollectionview.dataSource = self
            myImageCollectionview.delegate = self
            myImageCollectionview.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        }
    }
    
    weak var delegate: TableViewCellDelegate?
    private var albumModel: AlbumModel?
    private var imageArray: [UIImage] = []

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Configure Cell
    func configure(with model: AlbumModel) {
        self.albumModel = model
        albumNameLabel.text = model.albumName
        self.imageArray = model.thumImages // show thumbnails
        myImageCollectionview.reloadData()
    }
    
    // MARK: - Update Images
    func updateImages(_ model: AlbumModel) {
        self.albumModel = model
        self.imageArray = model.thumImages
        myImageCollectionview.reloadData()
    }
    
    // MARK: - Insert New Images
    func insertImages(_ newImages: [UIImage]) {
        let startIndex = imageArray.count
        imageArray.append(contentsOf: newImages)
        
        var indexPaths: [IndexPath] = []
        for i in 0..<newImages.count {
            indexPaths.append(IndexPath(item: startIndex + i, section: 0))
        }
        myImageCollectionview.insertItems(at: indexPaths)
    }

    @IBAction func addImgAction() {
        delegate?.addImageButtonTapped(in: self)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension TableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(image: imageArray[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let albumName = albumModel?.albumName {
            delegate?.imageTapped(in: self, at: indexPath, name: albumName)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 3 - 2, height: 179)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
