
import UIKit
protocol TableViewCellDelegate: AnyObject {
    func addImageButtonTapped(in cell: TableViewCell)
    func imageTapped(in cell: TableViewCell,  at: IndexPath, name: String)
}

class TableViewCell: UITableViewCell {

    @IBOutlet weak var myImageCollectionview: UICollectionView!
    {
        didSet{
            myImageCollectionview.dataSource = self
            myImageCollectionview.delegate = self
            myImageCollectionview.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        }
    }
    @IBOutlet weak var albumName: UILabel!
    
    var albumNameText: String?
    let manager = DatabaseManager()
    weak var delegate: TableViewCellDelegate?
    private var imageArray: [UIImage] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    func configure(with album: ALBUM) {
        albumNameText = album.albumName
        albumName.text = album.albumName
        updateImages()
    }
    
    func updateImages() {
        if let albumNameText = albumNameText {
            imageArray = manager.loadImages(from: albumNameText)
            myImageCollectionview.reloadData()
              }
        }

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

extension TableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(image: imageArray[indexPath.row])
        return cell
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let albumName = albumNameText {
            delegate?.imageTapped(in: self, at: indexPath, name: albumName)
        }
    }
}

