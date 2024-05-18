//
//  ViewController.swift
//  SeaFood
//
//  Created by Mayur Vaity on 17/05/24.
//

import UIKit
import CoreML
import Vision       //will help with processing these images

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    //creating image picker obj
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //assigning delegate of image picker with self
        imagePicker.delegate = self
        //.camera to get image from camera
        imagePicker.sourceType = .camera
        //.camera to get image from photoLibrary
//        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    //it is a delegate method, get called once image picker UIVC finishes getting a pic
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //one of the parameters info keeps data (including image taken), by specifying key we can get image
        // parameter info is a dictionary
        //using if-let to optional check image
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //assigning this image to ImageVw
            imageView.image = userPickedImage
            
            //to use it in the CoreML, need to convert it into CIImage
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage.")
            }
            
            //calling detect method to interpret/ classify our image
            detect(image: ciimage)
        }
        
        //need to dismiss this image picker UIVC and go back to original VC
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //to process our image and get interpretation/ classification out of it
    func detect(image: CIImage) {
        //creating an obj of our CoreML model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed.")
        }
        //creating a request to process that image
        let request = VNCoreMLRequest(model: model) { request, error in
            //getting result from request
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            //if above runs successfully, we should get a result
//            print(result)
            //checking 1st result for hotdog 
            if let firstResult = result.first {
                print(firstResult)
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        //to perform this request, it will need a handler, below is that handler
        let handler = VNImageRequestHandler(ciImage: image)
        
        //perform this request
        do {
            try handler.perform([request])
        } catch {
            print("Error while performing request, \(error)")
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        //to call imagePicker uiviewcontroller
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

