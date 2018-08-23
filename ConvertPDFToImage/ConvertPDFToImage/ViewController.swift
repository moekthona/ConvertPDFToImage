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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pdfFilePath = Bundle.main.path(forResource: "SwiftLanguage", ofType: "pdf")
        let sourceURL = URL(fileURLWithPath: pdfFilePath!)
        let imageArr = try! convertPDF(at: sourceURL,fileType: .png, dpi: 200)
        print("imageArr",imageArr.count)
        
        let imagePDF = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:  self.view.frame.height))
        
        imagePDF.image = UIImage(cgImage: imageArr[10])
        self.view.addSubview(imagePDF)
        
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
    
    func convertPDF(at sourceURL: URL, fileType: ImageFileType, dpi: CGFloat = 200) throws ->[CGImage] {
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
        return arrImage
    }
    
}

