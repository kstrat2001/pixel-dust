//
//  ViewController.swift
//  PixelDust
//
//  Created by Kain Osterholt on 10/27/18.
//  Copyright © 2018 Kain Osterholt. All rights reserved.
//

import UIKit
import PixelDust

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.changeBackgroundColor(_:)))
        self.view.addGestureRecognizer(gesture)

        //compareImagesNamed(image1: "black", image2: "white")
        //compareImagesNamed(image1: "image1", image2: "image1")
        //compareImagesNamed(image1: "image1", image2: "image1-different")
        //compareImagesNamed(image1: "image1", image2: "image1-different")
    }

    private func compareImagesNamed(image1: String, image2: String) {
        guard let uiImage1 = UIImage(named: image1),
              let uiImage2 = UIImage(named: image2) else {
                assertionFailure("Test requires 2 valid images")
                return
        }

        let start = Date()
        let comparator = ImageComparator(image: uiImage1, image2: uiImage2)
        let imagesMatch = comparator.compare()

        let end = start.timeIntervalSinceNow * -1000.0 // convert to ms
        print("Compare time for \(image1) & \(image2): \(end) milliseconds")
        let matchStr = imagesMatch ? "match" : "do not match"
        print("\(image1) & \(image2) \(matchStr)")
        
        if !imagesMatch {
            imageView.image = comparator.getDiffImage()
        }
    }

    @objc func changeBackgroundColor(_ sender: UITapGestureRecognizer) {
        if imageView.backgroundColor == .white {
            imageView.backgroundColor = .black
        } else {
            imageView.backgroundColor = .white
        }
    }
}
