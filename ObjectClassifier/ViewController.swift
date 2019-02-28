//
//  ViewController.swift
//  ObjectClassifier
//
//  Created by Brandon Mahoney on 2/27/19.
//  Copyright © 2019 Brandon Mahoney. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else { fatalError("Could not convert UIImage into CIImage.") }
            
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { fatalError("Loading CoreML Model failed.") }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Model failed to process image.") }
            
            if let firstResult = results.first {
                let confidence = firstResult.confidence * 100
                let confidenceString = String(format:"%.2f", confidence)
                self.classificationLabel.isHidden = false
                self.classificationLabel.text = "\nYour Result:\n\(firstResult.identifier)\nConfidence: \(confidenceString)%\n"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    

    
    @IBAction func selectImage(_ sender: UIBarButtonItem) {
        if sender.tag == 1 {
            imagePicker.sourceType = .photoLibrary
        } else {
            imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }

}

