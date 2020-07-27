//
//  NewPlacesTableViewController.swift
//  FavPlaces
//
//  Created by Алексей Зимовец on 16.07.2020.
//  Copyright © 2020 Алексей Зимовец. All rights reserved.
//

import UIKit

class NewPlacesTableViewController: UITableViewController {
    
    var currentPlace: Places?
    var imageIsChanged = true
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textLocationn: UITextField!
    @IBOutlet weak var textType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        textName.addTarget(self, action: #selector(textFieldChange), for: .editingChanged)
        setupEditScreen()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(sourse: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(sourse: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    func savePlaces(){

        var image: UIImage?
        
        if imageIsChanged {
            image = imageOfPlace.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
        
        let newPlaces = Places(name: textName.text!, location: textLocationn.text, type: textType.text, imageData: imageData)
        if currentPlace != nil{
            try! realm.write{
                currentPlace?.name = newPlaces.name
                currentPlace?.type = newPlaces.type
                currentPlace?.location = newPlaces.location
                currentPlace?.imageData = newPlaces.imageData
            }
        } else{
             StorageManager.saveObject(newPlaces)
        }
    }
    
    private func setupEditScreen(){
        if currentPlace != nil{
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            
            imageOfPlace.image = image
            imageOfPlace.contentMode = .scaleAspectFill
            textName.text = currentPlace?.name
            textType.text = currentPlace?.type
            textLocationn.text = currentPlace?.location
        }
    }
    
    private func setupNavigationBar(){
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
//Mark: TextField Delegate

extension NewPlacesTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc private func textFieldChange(){
    if textName.text?.isEmpty == false {
        saveButton.isEnabled = true
    } else {
        saveButton.isEnabled = false
    }
   }
}
 
extension NewPlacesTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(sourse){
            
         let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourse
            present(imagePicker, animated: true)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        dismiss(animated: true)
    }
}
