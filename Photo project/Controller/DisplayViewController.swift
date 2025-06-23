

import UIKit
class DisplayViewController: UIViewController {

    var centerCell: DisplayVCSecondCell?
    var previousIndex: IndexPath?
    var shouldScroll = true
    var imagesAr: [UIImage] = []
    var selectedImageIndex: IndexPath?
    var mayCollectionViewFlowLayout = MyCollectionViewFlowLayout()
    var viewtitle: String = ""
    var isThisViewLoaded = false
    @IBOutlet weak var firstCollectionView: UICollectionView!
    {
        didSet{
            self.firstCollectionView.dataSource = self
            self.firstCollectionView.delegate = self
            self.firstCollectionView.register(UINib(nibName: "DisplayVCfirstCell", bundle: nil), forCellWithReuseIdentifier: "DisplayVCfirstCell")
        }
    }
    @IBOutlet weak var secondCollectionView: UICollectionView!
    {
        didSet{
            self.secondCollectionView.dataSource = self
            self.secondCollectionView.delegate = self
            self.secondCollectionView.register(UINib(nibName: "DisplayVCSecondCell", bundle: nil), forCellWithReuseIdentifier: "DisplayVCSecondCell")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.secondCollectionView.collectionViewLayout = self.mayCollectionViewFlowLayout
        setUpView()
        
        }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let sideInset = (self.view.frame.width / 2) - (32 / 2)
//        self.secondCollectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
//        self.view.layoutIfNeeded()
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalWidth = self.view.frame.width
        let cellWidth: CGFloat = 32
        let sideInset = (totalWidth - cellWidth) / 2
        
        self.secondCollectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        self.view.layoutIfNeeded()
    }

    
    
    override func viewWillLayoutSubviews() {
        if !isThisViewLoaded{
            isThisViewLoaded = true
            
            DispatchQueue.main.async {
                self.firstCollectionView.isPagingEnabled = false
                if let index = self.selectedImageIndex {
                    self.firstCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                }
                self.firstCollectionView.isPagingEnabled = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstCollectionView.collectionViewLayout.invalidateLayout()
    }

    
    
    func setUpView() {
        self.navigationItem.title = viewtitle
        if let index = selectedImageIndex {
            self.firstCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        }
        self.secondCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == firstCollectionView {
            let index = Int(round(scrollView.contentOffset.x / firstCollectionView.frame.width))
            let indexPath = IndexPath(item: index, section: 0)
            
            // Ensure secondCollectionView is always centered
            self.secondCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}

extension DisplayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesAr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == firstCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayVCfirstCell", for: indexPath) as! DisplayVCfirstCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.firstImageView.image = imagesAr[indexPath.row]
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayVCSecondCell", for: indexPath) as! DisplayVCSecondCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.configure(image:  imagesAr[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == firstCollectionView {
            return CGSize(width: collectionView.frame.width, height: 275)
        } else {
            return CGSize(width: 32, height: 32)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == secondCollectionView{
            return 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == firstCollectionView {
            // MARK : FOR ZOOM IN AND ZOOM OUT
            let imageInfo = GSImageInfo(image: imagesAr[indexPath.row], imageMode: .aspectFit)
            let transitionInfo = GSTransitionInfo(fromView: collectionView)
            let imageViwer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            present(imageViwer, animated: true)
            // END
        }
        else {
            if previousIndex != nil {
                
                let previousCell = secondCollectionView.cellForItem(at: previousIndex!) as! DisplayVCSecondCell
                previousCell.transformToStandard()
            }
            shouldScroll = false
            self.secondCollectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
            
            let cell = secondCollectionView.cellForItem(at: indexPath) as! DisplayVCSecondCell
            cell.transformToLarge()
            
            previousIndex = indexPath
            
            self.firstCollectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: false)
            shouldScroll = true
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == firstCollectionView {
            let index = Int(round(scrollView.contentOffset.x / firstCollectionView.frame.width))
            let indexPath = IndexPath(item: index, section: 0)

            if let previousIndex = previousIndex, let previousCell = secondCollectionView.cellForItem(at: previousIndex) as? DisplayVCSecondCell {
                previousCell.transformToStandard()
            }

            secondCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            if let cell = secondCollectionView.cellForItem(at: indexPath) as? DisplayVCSecondCell {
                cell.transformToLarge()
                previousIndex = indexPath
            }
        }
    }

}
