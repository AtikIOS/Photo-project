
import Foundation
import CoreData
import UIKit

class DatabaseManager {
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    func saveAlbum(albmName: String) -> ALBUM? {
        let albm = ALBUM(context: context)
        albm.albumName = albmName
        albm.createdDate = Date()
        saveContext()
        return albm
    }
    
    func fetchAlbums() -> [ALBUM] {
        do {
            let fetchRequest: NSFetchRequest<ALBUM> = ALBUM.fetchRequest()
            let sort = NSSortDescriptor(key: "createdDate", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching albums: ", error)
            return []
        }
    }
    
    func deleteAlbum(album: ALBUM) {
        context.delete(album)
        saveContext()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    // MARK :  documents directory URL
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveImage(_ image: UIImage, albumName: String) -> Bool {
        let albumDirectory = getDocumentsDirectory().appendingPathComponent(albumName)
        let imageName = image.accessibilityIdentifier ?? UUID().uuidString + ".jpg"
        print("imageName , \(imageName)")
        let imageURL = albumDirectory.appendingPathComponent(imageName)

        // MARK : Check if the image already exists
        if FileManager.default.fileExists(atPath: imageURL.path) {
            return false
        }
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                // MARK : Create album directory if it doesn't exist
                if !FileManager.default.fileExists(atPath: albumDirectory.path) {
                    try FileManager.default.createDirectory(at: albumDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                try imageData.write(to: imageURL)
                print("imageURL, \(imageURL)")
                return true
            } catch {
                print("Error saving image: \(error)")
                return false
            }
        }
        return false
    }

    func loadImages(from albumName: String) -> [UIImage] {
        var imagesArray: [UIImage] = []
        let albumDirectory = getDocumentsDirectory().appendingPathComponent(albumName)

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: albumDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    imagesArray.append(image)
                }
            }
        } catch {
            print("Error fetching images: \(error)")
        }
        return imagesArray
    }
}

