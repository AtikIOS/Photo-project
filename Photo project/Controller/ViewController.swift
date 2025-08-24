//
//  DisplayVCfirstCell.swift
//  Photo project
//
//  Created by Atik Hasan on 8/16/24.
//

import UIKit
import Foundation
import PhotosUI

class ViewController: UIViewController {

    @IBOutlet weak var myImageTableView: UITableView!
    var data: [AlbumModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Atik Gallery"
        setupTableView()
        
        // Fetch all albums and images
        Common.shared.fetchAllAlbumsAndImages()
        self.data = Common.shared.albums
        myImageTableView.reloadData()
    }

    func setupTableView() {
        myImageTableView.dataSource = self
        myImageTableView.delegate = self
        myImageTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }

    @IBAction func addAlbumAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Album", message: "Enter album name", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Album Name"
        }
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self,
                  let albumName = alertController.textFields?.first?.text,
                  !albumName.isEmpty else { return }
            
            if let savedAlbum = DatabaseManager.shared.saveAlbum(albmName: albumName) {
                Common.shared.fetchAllAlbumsAndImages()
                self.data = Common.shared.albums
                self.myImageTableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }

        let album = data[indexPath.row]
        cell.configure(with: album)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 232
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let albumNameToDelete = data[indexPath.row].albumName
            DatabaseManager.shared.deleteAlbum(byName: albumNameToDelete)
            Common.shared.fetchAllAlbumsAndImages()
            self.data = Common.shared.albums
            myImageTableView.reloadData()
        }
    }
}

// MARK: - TableViewCell Delegate
extension ViewController: TableViewCellDelegate {

    func imageTapped(in cell: TableViewCell, at index: IndexPath, name: String) {
        guard let indexPath = self.myImageTableView.indexPath(for: cell) else { return }
        let selectedAlbum = data[indexPath.row]
        let images = selectedAlbum.images
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let displayVC = storyboard.instantiateViewController(withIdentifier: "DisplayViewController") as? DisplayViewController {
            displayVC.imagesAr = images
            displayVC.thumImageAr = selectedAlbum.thumImages
            displayVC.selectedImageIndex = index
            displayVC.viewtitle = name
            self.navigationController?.pushViewController(displayVC, animated: true)
        }
    }

    func addImageButtonTapped(in cell: TableViewCell) {
        guard let indexPath = self.myImageTableView.indexPath(for: cell) else { return }
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.view.tag = indexPath.row
        present(picker, animated: true)
    }
}

// MARK: - PHPicker Delegate
extension ViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let albumIndex = picker.view.tag
        let albumName = data[albumIndex].albumName

        var newImages: [UIImage] = []
        var duplicateCount = 0
        let group = DispatchGroup()

        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let image = object as? UIImage {
                        if DatabaseManager.shared.saveImage(image, albumName: albumName) {
                            newImages.append(image)
                        } else {
                            duplicateCount += 1
                        }
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else {return}
            Common.shared.fetchAllAlbumsAndImages()
            self.data = Common.shared.albums
            self.myImageTableView.reloadData()

            if duplicateCount > 0 {
                self.showDuplicateAlert(count: duplicateCount)
            }
        }
    }

    func showDuplicateAlert(count: Int) {
        let alert = UIAlertController(title: "Duplicate Image", message: "\(count) images already exist in this album.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
