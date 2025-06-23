
import UIKit
import PhotosUI
class ViewController: UIViewController {

    @IBOutlet weak var myImageTableView: UITableView!
    private var albumArray: [ALBUM] = []
    private let manager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Atik Gallery"
        setupTableView()
        albumArray = manager.fetchAlbums()
        myImageTableView.reloadData()
    }
    
    func setupTableView() {
        myImageTableView.dataSource = self
        myImageTableView.delegate = self
        myImageTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }

    @IBAction func addAlbumAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Album", message: "Enter album name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Album Name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            if let albumName = alertController.textFields?.first?.text, !albumName.isEmpty {
                if let name = self?.manager.saveAlbum(albmName: albumName) {
                    self?.albumArray.insert(name, at: 0)
                    self?.myImageTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        let album = albumArray[indexPath.row]
        cell.configure(with: album)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 232
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let albumToDelete = albumArray[indexPath.row]
            manager.deleteAlbum(album: albumToDelete)
            albumArray.remove(at: indexPath.row)
            myImageTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ViewController: TableViewCellDelegate {
    func imageTapped(in cell: TableViewCell,  at index: IndexPath, name: String) {
        guard let indexPath = myImageTableView.indexPath(for: cell) else { return }
        let selectedAlbum = albumArray[indexPath.row]
        let images = manager.loadImages(from: selectedAlbum.albumName ?? "")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let displayVC = storyboard.instantiateViewController(withIdentifier: "DisplayViewController") as? DisplayViewController {
            displayVC.imagesAr = images
            displayVC.selectedImageIndex = index
            displayVC.viewtitle = name
            navigationController?.pushViewController(displayVC, animated: true)
        }
    }
    
    func addImageButtonTapped(in cell: TableViewCell) {
        guard let indexPath = myImageTableView.indexPath(for: cell) else { return }
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.view.tag = indexPath.row
        present(picker, animated: true, completion: nil)
    }
}



//
extension ViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
           picker.dismiss(animated: true, completion: nil)
           
           let albumIndex = picker.view.tag
           let albumName = albumArray[albumIndex].albumName ?? ""
           
           var newImages: [UIImage] = []
           var duplicateImageCount = 0
           let group = DispatchGroup()
           for result in results {
               if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                   result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                       if let image = object as? UIImage {
                           image.accessibilityIdentifier = result.itemProvider.suggestedName
                           print("vc", image)
                           if let isSaved = self?.manager.saveImage(image, albumName: albumName), isSaved {
                               newImages.append(image)
                           } else {
                                        duplicateImageCount += 1
                           }
                       }
                       group.leave()
                   }
               }
           }
          
           group.notify(queue: .main) {
               if let cell = self.myImageTableView.cellForRow(at: IndexPath(row: albumIndex, section: 0)) as? TableViewCell {
                   cell.insertImages(newImages)
               }
               if duplicateImageCount > 0 {
                 self.DuplicateImageShowAlert(count: duplicateImageCount)
               }
           }
       }
    
}

extension ViewController
{
   
    func DuplicateImageShowAlert(count : Int)
    {
        let alert = UIAlertController(title: "Duplicate Image", message: "\(count) images already exists in the album.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
