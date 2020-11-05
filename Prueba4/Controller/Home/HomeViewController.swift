//
//  HomeViewController.swift
//  prueba3
//
//  Created by Sergio Vizcarro on 19/08/2020.
//  Copyright © 2020 Sergio Vizcarro. All rights reserved.
//

import UIKit
import MLKit
import AVFoundation
import CoreVideo


//import Vision
//import MLKitTextRecognition  // LA REPUTA Q TE PARIO MAMAHUEBO
//import VisionKit
//import FirebaseMLVision
//import TesseractOCR

final class HomeViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Propiedades
    private let detectors: [Detector] = [
      .onDeviceBarcode,
      .onDeviceFace,
      .onDeviceText,
      .onDeviceObjectProminentNoClassifier,
      .onDeviceObjectProminentWithClassifier,
      .onDeviceObjectMultipleNoClassifier,
      .onDeviceObjectMultipleWithClassifier,
      .onDeviceObjectCustomProminentNoClassifier,
      .onDeviceObjectCustomProminentWithClassifier,
      .onDeviceObjectCustomMultipleNoClassifier,
      .onDeviceObjectCustomMultipleWithClassifier,
      .poseFast,
      .poseAccurate,
    ]
    private var currentDetector: Detector = .onDeviceFace
    private var isUsingFrontCamera = true
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    private var lastFrame: CMSampleBuffer?
    
    
    private lazy var previewOverlayView: UIImageView = {

      precondition(isViewLoaded)
      let previewOverlayView = UIImageView(frame: .zero)
      previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
      previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return previewOverlayView
    }()
    
    private lazy var annotationOverlayView: UIView = {
      precondition(isViewLoaded)
      let annotationOverlayView = UIView(frame: .zero)
      annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return annotationOverlayView
    }()
    
    private lazy var textRecognizer = TextRecognizer.textRecognizer()
    
    @IBOutlet weak var textView: UILabel!
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    
    
    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //let vision = Vision.vision()
        //textRecognizer = vision.onDeviceTextRecognizer()
    }

    // Abre la galeria
    @IBAction func openPhotoLibraryButton(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func RecognizeText(_ sender: Any) {
//        setupVisionTextRecognizeImage(image: imagePicked.image)

        let vi = VisionImage(image: imagePicked.image!)
        recognizeTextOnDevice(in: vi, width: 300, height: 300)
      
        
    }
    
    
    
    // MARK: - Métodos
//
//    func textRecognize(_ img: UIImage){
//        var visionImage: VisionImage
//        let image = VisionImage(image: img)
//        visionImage.orientation = image
//    }
    private func recognizeTextOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
        print("hola")
      var recognizedText: Text
      do {
        recognizedText = try TextRecognizer.textRecognizer().results(in: image)
      } catch let error {
        print("Failed to recognize text with error: \(error.localizedDescription).")
        return
      }
      DispatchQueue.main.sync {
        self.updatePreviewOverlayView()
        self.removeDetectionAnnotations()

        // Blocks.
        for block in recognizedText.blocks {
          let points = self.convertedPoints(from: block.cornerPoints, width: width, height: height)
          UIUtilities.addShape(
            withPoints: points,
            to: self.annotationOverlayView,
            color: UIColor.purple
          )

          // Lines.
          for line in block.lines {
            let points = self.convertedPoints(from: line.cornerPoints, width: width, height: height)
            UIUtilities.addShape(
              withPoints: points,
              to: self.annotationOverlayView,
              color: UIColor.orange
            )

            // Elements.
            for element in line.elements {
              let normalizedRect = CGRect(
                x: element.frame.origin.x / width,
                y: element.frame.origin.y / height,
                width: element.frame.size.width / width,
                height: element.frame.size.height / height
              )

              let convertedRect = self.previewLayer.layerRectConverted(
                fromMetadataOutputRect: normalizedRect
              )
              UIUtilities.addRectangle(
                convertedRect,
                to: self.annotationOverlayView,
                color: UIColor.green
              )
              let label = UILabel(frame: convertedRect)

              label.text = element.text
              label.adjustsFontSizeToFitWidth = true
              self.annotationOverlayView.addSubview(label)
            }
          }
        }
      }
    }
    
    
    
    // Coloca la imagen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("coloco img")
            imagePicked.image = image
            
        }
    }
    
    private func removeDetectionAnnotations() {
      for annotationView in annotationOverlayView.subviews {
        annotationView.removeFromSuperview()
      }
    }

    private func updatePreviewOverlayView() {
      guard let lastFrame = lastFrame,
        let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
      else {
        return
      }
      let ciImage = CIImage(cvPixelBuffer: imageBuffer)
      let context = CIContext(options: nil)
      guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return
      }
      let rotatedImage = UIImage(cgImage: cgImage, scale: Constant.originalScale, orientation: .right)
      if isUsingFrontCamera {
        guard let rotatedCGImage = rotatedImage.cgImage else {
          return
        }
        let mirroredImage = UIImage(
          cgImage: rotatedCGImage, scale: Constant.originalScale, orientation: .leftMirrored)
        previewOverlayView.image = mirroredImage
      } else {
        previewOverlayView.image = rotatedImage
      }
    }
    
    private func convertedPoints(
      from points: [NSValue]?,
      width: CGFloat,
      height: CGFloat
    ) -> [NSValue]? {
      return points?.map {
        let cgPointValue = $0.cgPointValue
        let normalizedPoint = CGPoint(x: cgPointValue.x / width, y: cgPointValue.y / height)
        let cgPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
        let value = NSValue(cgPoint: cgPoint)
        return value
      }
    }
}

// MARK: - Constants
public enum Detector: String {
  case onDeviceBarcode = "On-Device Barcode Scanner"
  case onDeviceFace = "On-Device Face Detection"
  case onDeviceText = "On-Device Text Recognition"
  case onDeviceObjectProminentNoClassifier = "ODT, single, no labeling"
  case onDeviceObjectProminentWithClassifier = "ODT, single, labeling"
  case onDeviceObjectMultipleNoClassifier = "ODT, multiple, no labeling"
  case onDeviceObjectMultipleWithClassifier = "ODT, multiple, labeling"
  case onDeviceObjectCustomProminentNoClassifier = "ODT, custom, single, no labeling"
  case onDeviceObjectCustomProminentWithClassifier = "ODT, custom, single, labeling"
  case onDeviceObjectCustomMultipleNoClassifier = "ODT, custom, multiple, no labeling"
  case onDeviceObjectCustomMultipleWithClassifier = "ODT, custom, multiple, labeling"
  case poseAccurate = "Pose, accurate"
  case poseFast = "Pose, fast"
}

private enum Constant {
  static let alertControllerTitle = "Vision Detectors"
  static let alertControllerMessage = "Select a detector"
  static let cancelActionTitleText = "Cancel"
  static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
  static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
  static let noResultsMessage = "No Results"
  static let localModelFile = (name: "bird", type: "tflite")
  static let labelConfidenceThreshold: Float = 0.75
  static let smallDotRadius: CGFloat = 4.0
  static let lineWidth: CGFloat = 3.0
  static let originalScale: CGFloat = 1.0
  static let padding: CGFloat = 10.0
  static let resultsLabelHeight: CGFloat = 200.0
  static let resultsLabelLines = 5
}
