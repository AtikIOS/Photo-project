

import UIKit

class DisplayViewController: UIViewController {
    
    @IBOutlet weak var firstCollectionView: UICollectionView!{
        didSet{
            self.firstCollectionView.dataSource = self
            self.firstCollectionView.delegate = self
            self.firstCollectionView.register(UINib(nibName: "DisplayVCfirstCell", bundle: nil), forCellWithReuseIdentifier: "DisplayVCfirstCell")
        }
    }
    @IBOutlet weak var secondCollectionView: UICollectionView!{
        didSet{
            self.secondCollectionView.dataSource = self
            self.secondCollectionView.delegate = self
            self.secondCollectionView.register(UINib(nibName: "DisplayVCSecondCell", bundle: nil), forCellWithReuseIdentifier: "DisplayVCSecondCell")
        }
    }
    
    var centerCell: DisplayVCSecondCell?
    var previousIndex: IndexPath?
    var shouldScroll = true
    var imagesAr: [UIImage] = []
    var thumImageAr : [UIImage] = []
    var selectedImageIndex: IndexPath?
    var mayCollectionViewFlowLayout = MyCollectionViewFlowLayout()
    var viewtitle: String = ""
    var isThisViewLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.secondCollectionView.collectionViewLayout = self.mayCollectionViewFlowLayout
        let layout = CenteredCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 32, height: 32) // thumbnail size
        secondCollectionView.collectionViewLayout = layout
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let totalWidth = self.view.frame.width
        let cellWidth: CGFloat = 32
        let sideInset = (totalWidth - cellWidth) / 2
        
        self.secondCollectionView.contentInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        self.view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        if !isThisViewLoaded {
            isThisViewLoaded = true
            DispatchQueue.main.async {
                // Scroll firstCollectionView only (no transform)
                if let index = self.selectedImageIndex {
                    self.firstCollectionView.isPagingEnabled = false
                    self.firstCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                    self.firstCollectionView.isPagingEnabled = true

                    // Transform secondCollectionView selected cell
                    if let cell = self.secondCollectionView.cellForItem(at: index) as? DisplayVCSecondCell {
                        cell.transformToLarge()
                        self.previousIndex = index
                    } else {
                        self.secondCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
                        self.secondCollectionView.layoutIfNeeded()
                        if let cell = self.secondCollectionView.cellForItem(at: index) as? DisplayVCSecondCell {
                            cell.transformToLarge()
                            self.previousIndex = index
                        }
                    }
                }
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
    
    deinit {
        print("DisplayViewController deallocated")
        imagesAr.removeAll()
        thumImageAr.removeAll()
        firstCollectionView.delegate = nil
        firstCollectionView.dataSource = nil
        secondCollectionView.delegate = nil
        secondCollectionView.dataSource = nil
    }

}


extension DisplayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
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
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayVCSecondCell", for: indexPath) as! DisplayVCSecondCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.configure(image: thumImageAr[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == firstCollectionView {
            return CGSize(width: collectionView.frame.width, height: 275)
        } else {
            return CGSize(width: 32, height: 32)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == secondCollectionView {
            return 3
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == firstCollectionView {
            // MARK: For zoom-in
            let imageInfo = GSImageInfo(image: imagesAr[indexPath.row], imageMode: .aspectFit)
            let transitionInfo = GSTransitionInfo(fromView: collectionView)
            let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            present(imageViewer, animated: true)
        } else {
            // MARK: Second CollectionView Tap
            if let previousIndex = previousIndex,
               let previousCell = secondCollectionView.cellForItem(at: previousIndex) as? DisplayVCSecondCell {
                previousCell.transformToStandard()
            }
            
            let cell = secondCollectionView.cellForItem(at: indexPath) as! DisplayVCSecondCell
            cell.transformToLarge()
            
            previousIndex = indexPath
            
            // ✅ Center the tapped cell
            centerCellInSecondCollectionView(at: indexPath, animated: true)
            
            // Sync firstCollectionView
            firstCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == firstCollectionView {
            let index = Int(round(scrollView.contentOffset.x / firstCollectionView.frame.width))
            let indexPath = IndexPath(item: index, section: 0)
            centerCellInSecondCollectionView(at: indexPath, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == firstCollectionView {
            let index = Int(round(scrollView.contentOffset.x / firstCollectionView.frame.width))
            let indexPath = IndexPath(item: index, section: 0)
            
            if let previousIndex = previousIndex,
               let previousCell = secondCollectionView.cellForItem(at: previousIndex) as? DisplayVCSecondCell {
                previousCell.transformToStandard()
            }
            
            if let cell = secondCollectionView.cellForItem(at: indexPath) as? DisplayVCSecondCell {
                cell.transformToLarge()
                previousIndex = indexPath
            }
            
            // ✅ Center the selected cell
            centerCellInSecondCollectionView(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Helper to center cell in secondCollectionView
    func centerCellInSecondCollectionView(at indexPath: IndexPath, animated: Bool) {
        guard let layout = secondCollectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              let attributes = layout.layoutAttributesForItem(at: indexPath) else { return }
        
        let cellFrame = attributes.frame
        let offsetX = cellFrame.midX - secondCollectionView.bounds.width / 2
        let adjustedOffsetX = max(0, min(offsetX, secondCollectionView.contentSize.width - secondCollectionView.bounds.width))
        
        secondCollectionView.setContentOffset(CGPoint(x: adjustedOffsetX, y: 0), animated: animated)
    }
}



class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }

        let collectionViewSize = collectionView.bounds.size
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width / 2

        guard let attributesForVisibleCells = layoutAttributesForElements(in: collectionView.bounds) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        var candidateAttributes: UICollectionViewLayoutAttributes?
        for attributes in attributesForVisibleCells {
            if attributes.representedElementCategory != .cell {
                continue
            }

            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }

            if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }

        guard let finalAttributes = candidateAttributes else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        let newOffsetX = finalAttributes.center.x - collectionView.bounds.size.width / 2
        let offset = CGPoint(x: max(0, min(newOffsetX, collectionView.contentSize.width - collectionView.bounds.width)), y: proposedContentOffset.y)
        return offset
    }

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        scrollDirection = .horizontal
        minimumLineSpacing = 0
        let inset = (collectionView.bounds.width - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

