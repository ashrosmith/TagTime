//
//  ViewController.swift
//  TagTime
//
//  Created by Ashley Smith on 3/14/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = K.title
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
//MARK: - Image Picker
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userImage
            guard let ciimage = CIImage(image: userImage) else {
                fatalError("Could not convert to CI Image.")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
//MARK: - Core ML Processing
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: TagClassifier(configuration: MLModelConfiguration()).model) else {
            fatalError("CoreML Model failed to load.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains(K.vintage) {
                    self.navigationItem.title = K.itemIsVintage
                    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.39, green: 0.59, blue: 0.40, alpha: 1.00)]
            
                } else if firstResult.identifier.contains(K.modern) {
                    self.navigationItem.title = K.itemIsModern
                    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.71, green: 0.33, blue: 0.37, alpha: 1.00)]
                } else {
                    self.navigationItem.title = K.cannotBeDetermined
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
}

