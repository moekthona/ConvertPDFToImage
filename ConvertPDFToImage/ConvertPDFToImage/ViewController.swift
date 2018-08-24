//
//  ViewController.swift
//  ConvertPDFToImage
//
//  Created by Thona on 8/23/18.
//  Copyright © 2018 Thona. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {

    var loading : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading = UIViewController.displaySpinner(onView: self.view)
        
        let url = URL(string: "https://drive.google.com/uc?export=download&id=0Bz_c6UWaP7KYc3RhcnRlcl9maWxl")
        load(url: url!) { (temUrl) in
            
            let pdfFilePath = Bundle.main.bundlePath + "/book.pdf"
            try! FileManager.default.copyItem(at: temUrl, to: URL(fileURLWithPath: pdfFilePath))
            let sourceURL = URL(fileURLWithPath: pdfFilePath)

            try! self.convertPDF(at: sourceURL, fileType: .png, completion: { (arrImage) in
                
                DispatchQueue.main.async {
                    let img = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                    self.view.addSubview(img)
                    img.image = UIImage(cgImage: arrImage[0])
                    img.contentMode = .scaleAspectFit
                    UIViewController.removeSpinner(spinner: self.loading!)
                }
                
            })
            
            
            print(pdfFilePath)
            
            
        }
    }
    
    struct ImageFileType {
        var uti: CFString
        var fileExtention: String
        
        // This list can include anything returned by CGImageDestinationCopyTypeIdentifiers()
        // I'm including only the popular formats here
        static let bmp = ImageFileType(uti: kUTTypeBMP, fileExtention: "bmp")
        static let gif = ImageFileType(uti: kUTTypeGIF, fileExtention: "gif")
        static let jpg = ImageFileType(uti: kUTTypeJPEG, fileExtention: "jpg")
        static let png = ImageFileType(uti: kUTTypePNG, fileExtention: "png")
        static let tiff = ImageFileType(uti: kUTTypeTIFF, fileExtention: "tiff")
    }
    
    //convert pdf to image
    
    func convertPDF(at sourceURL: URL, fileType: ImageFileType, dpi: CGFloat = 200,completion: @escaping ([CGImage]) -> ()) throws {
        let pdfDocument = CGPDFDocument(sourceURL as CFURL)!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.noneSkipLast.rawValue
        
        var arrImage = [CGImage]()
        DispatchQueue.concurrentPerform(iterations: pdfDocument.numberOfPages) { i in
            // Page number starts at 1, not 0
            let pdfPage = pdfDocument.page(at: i + 1)!
            
            let mediaBoxRect = pdfPage.getBoxRect(.mediaBox)
            let scale = dpi / 72.0
            let width = Int(mediaBoxRect.width * scale)
            let height = Int(mediaBoxRect.height * scale)
            
            let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo)!
            context.interpolationQuality = .high
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            context.scaleBy(x: scale, y: scale)
            context.drawPDFPage(pdfPage)
            
            let image = context.makeImage()!
            arrImage.append(image)
        }
        completion(arrImage)
    }
    
    
    //load pdf
    func load(url: URL, completion: @escaping (URL) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                completion(tempLocalUrl)
                
            } else {
                print("Failure: 3333");
            }
        }
        task.resume()
    }
    
}

extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

