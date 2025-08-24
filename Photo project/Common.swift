//
//  Common.swift
//  Photo project
//
//  Created by Atik Hasan on 8/24/25.
//

import UIKit
import Foundation

// MARK: - Album Model
struct AlbumModel {
    var albumName: String
    var images: [UIImage]
    var thumImages: [UIImage]
}

// MARK: - Common Class
class Common {
    
    static let shared = Common()
    var albums: [AlbumModel] = []
    
    private init() {}
    
    // Fetch all albums + images + generate thumbnails
    func fetchAllAlbumsAndImages() {
        albums.removeAll()
        let albumList = DatabaseManager.shared.fetchAlbums()
        for album in albumList {
            let name = album.albumName ?? ""
            let images = DatabaseManager.shared.loadImages(from: name)
            let thumbnails = generateThumbnails(for: images, targetSize: CGSize(width: 100, height: 100))
            let albumModel = AlbumModel(albumName: name, images: images, thumImages: thumbnails)
            albums.append(albumModel)
        }
        print(albums)
    }
    
     func generateThumbnails(for images: [UIImage], targetSize: CGSize) -> [UIImage] {
        var thumbnails: [UIImage] = []
        for image in images {
            if let thumb = image.resize(to: targetSize) {
                thumbnails.append(thumb)
            }
        }
        return thumbnails
    }
}


// MARK: - UIImage Extension for resizing
extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

