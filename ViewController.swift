//
//  ViewController.swift
//  ML
//
//  Created by wang on 06/05/2019.
//  Copyright © 2019 Wangdelz. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Social

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var displayText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var classificationResults : [VNClassificationObservation] = []
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "UI-img.jpeg")?.draw(in: self.view.bounds)
        
        if let image = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            self.view.backgroundColor = UIColor(patternImage: image)
        }else{
            UIGraphicsEndImageContext()
            debugPrint("Image not available")
        }
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
            
            detect(image: ciImage)
            
        }
        
    }
    
    func detect(image:CIImage){
        guard let model = try? VNCoreMLModel(for:Inceptionv3().model) else {
            fatalError("can't load ML model")
        }
        
        self.view.backgroundColor = UIColor.white
        
        let request = VNCoreMLRequest(model:model) { request,error in
            
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                  fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            if topResult.identifier.contains("hotdog") {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                    
                    
                }
            }
            else {
                DispatchQueue.main.async {
                    self.navigationItem.title = "\(topResult.identifier)"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                    self.navigationController?.navigationBar.sizeToFit()
                    let height: CGFloat = 250 //whatever height you want to add to the existing height
                    let bounds = self.navigationController!.navigationBar.bounds
                    self.navigationController?.navigationBar.frame = CGRect(x:-15.0, y: 0, width: bounds.width, height: bounds.height + height)
                    
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do { try handler.perform([request]) }
        catch { print(error) }
        
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker,animated: true,completion: nil)
        
    }
    
}

