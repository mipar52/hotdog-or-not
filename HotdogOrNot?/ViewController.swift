//
//  ViewController.swift
//  HotdogOrNot?
//
//  Created by Milan Parađina on 08/06/2020.
//  Copyright © 2020 Milan Parađina. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageProcess: UIImageView!
    @IBOutlet weak var hotdogResultLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var hotdogLabel = UILabel(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Press to camera button"
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageProcess.image = userPickedImage
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not process image.")
            }
           
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        print("Getting to know the image...")
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Could not generate an ML Model.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            print(results)
            
            if let firstResult = results.first {
                
                if firstResult.identifier.contains("hotdog"){
                    let percentige = "\(String(format: "%.2f", firstResult.confidence * 100))%"
                    self.hotdogResultLabel.text = "Found a hotdog!\n\(percentige) sure this is a hotdog"
                } else {
                    self.hotdogResultLabel.text = "That's not a hotdog!\nThat is a \(firstResult.identifier)"
            }
        }
    }

        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
            self.hotdogLabel.text = "Detecting if this is actually a hotdog..."
            print("In the do statement")
        } catch{
            print(error)
        }
//        print(request)
//        print(handler)
    }
    
     func addHotdogLabel(toImagePicker imagePicker: UIImagePickerController) {
        hotdogLabel.frame = imagePicker.cameraOverlayView!.frame
        hotdogLabel.textAlignment = .center
        imagePicker.cameraOverlayView = hotdogLabel
    }
    
    func openCamera() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        addHotdogLabel(toImagePicker: imagePicker)
        hotdogLabel.text = "Take a picture of a hotdog"
        hotdogLabel.textColor = .white
        
        present(imagePicker, animated: true, completion: nil)

    }

    @IBAction func cameraBtnPressed(_ sender: Any) {
        openCamera()
    }
}
