//
//  ViewController.swift
//  ImagesTest
//
//  Created by Abhang Mane @Goldmedal on 30/01/24.

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var imageLabel: UIImageView!
    @IBOutlet var browseButtonLabel: UIButton!
    @IBOutlet var uploadButtonLabel: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    public var imageBase64String:String = ""
    
    override func viewDidLoad() {
        self.browseButtonLabel.isHidden = false
        uploadButtonLabel.isHidden = true
    }
    
    @IBAction func browseClicked(_ sender: Any) {
        
        let vc = UIAlertController(title: "Select Image", message: "Select image from", preferredStyle: .actionSheet)
        let cameraBtn = UIAlertAction(title: "Camera", style: .default){[weak self] (_) in
            self?.showImagePicker(selectedSource: .camera)
            print("camera sequence")
        }
        
        let libraryBtn = UIAlertAction(title: "Library", style: .default){[weak self](_) in
            self?.showImagePicker(selectedSource: .photoLibrary)
            print("Library Selected")
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel)
        vc.addAction(cameraBtn)
        vc.addAction(libraryBtn)
        vc.addAction(cancelBtn)
        self.present(vc,animated: true,completion: nil)
    }
    
    @IBAction func updateClicked(_ sender: UIButton) {
        fetchDetails(imgBlob: imageBase64String)
    }
    
    
    func showImagePicker(selectedSource:UIImagePickerController.SourceType){
        //handling fatal error
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else{
            print("Selected Source Not Available")
            return
        }
        //image picker property set
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //set image as the selected image from the library
        if let selectedImage = info[.originalImage] as? UIImage{
            imageLabel.image = selectedImage
            
            //Get data of existing UIImage
            let imageData = selectedImage.jpegData(compressionQuality: 1)
            // Convert image Data to base64 encodded string
            self.imageBase64String = imageData!.base64EncodedString()
            //print(imageBase64String ?? "Could not encode image to Base64")
            self.browseButtonLabel.isHidden = true
            self.uploadButtonLabel.isHidden = false
            
        }
        else{
            print("Image not found")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    

    func fetchDetails(imgBlob:String){
        let apiURL = "https://crm-uat.goldmedalindia.in/api/Rituals/v1/manage/commonuploadimage"
        let moduleId = 20
        let imgString = imgBlob
        postImage(with: apiURL,moduleId:moduleId,imgString: imgString)
    }
    
    func postImage(with urlString: String, moduleId: Int,imgString:String){
        //1. Create URL
        if let url = URL(string: urlString) {
            //2. Create URLSession
            let session = URLSession(configuration: .default)
            
            //3. Prepare JSON data
            let userData = ["ModuleID": moduleId,"ImageBlob": imgString] as [String : Any]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userData)
                
                //4. Prepare URLRequest
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let task = session.dataTask(with: request) { data, response, error in
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                        print("Status Code = 200 Success")
                        print("response = \(response)")
                        DispatchQueue.main.async{
                        let successAlert = UIAlertController(title: "Success", message: "Successfully Uploaded Image", preferredStyle: UIAlertController.Style.alert)
                        let successAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                            self.imageLabel.image = nil
                            self.browseButtonLabel.isHidden = false
                            self.uploadButtonLabel.isHidden = true
                        })
                        successAlert.addAction(successAction)
                        self.present(successAlert, animated: true)
                        }
                        
                        
                    }
                    
                    else{
                        print("error")
                    }
                }
                task.resume()
            }catch{
                print("Error request response")
            }
        }
    }
    //Function to parse the JSON fetched form the apiurl and decode returning the details
    func parseJSON(_ detailsData: Data) {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(Data.self,from: detailsData)
            //print(decodedData)
            for i in decodedData{
                let fileName = i
                print("File Name: \(fileName)")
            }
        }
        catch{
            print(error)
        }
}
}
