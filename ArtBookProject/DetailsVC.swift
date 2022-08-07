//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Fatih Filizol on 2.08.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var txtYear: UITextField!
    @IBOutlet weak var txtArtist: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if chosenPainting != ""{
            
            saveButton.isHidden = true
            
            //Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            let idString = chosenPaintingId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey:  "name") as? String{
                            txtName.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            txtArtist.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int{
                            txtYear.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imgView.image = image
                        }
                    }
                }
            }catch{
                print("Error")
            }
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        //Recognizers

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imgView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imgView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imgView.image = info[.editedImage] as? UIImage
        
        saveButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(){
        
        view.endEditing(true)
        
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(txtName.text!, forKey: "name")
        if let year = Int(txtYear.text!) {
            newPainting.setValue(year, forKey:  "year")
        }
        newPainting.setValue(txtArtist.text!, forKey: "artist")
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imgView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Success")
        }catch{
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    
    

}
