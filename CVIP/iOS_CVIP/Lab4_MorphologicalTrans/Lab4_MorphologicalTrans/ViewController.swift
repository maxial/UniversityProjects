//
//  ViewController.swift
//  Lab4_MorphologicalTrans
//
//  Created by Maxim Aliev on 16/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageViewB: UIImageView!
    @IBOutlet weak var imageViewB1: UIImageView!
    @IBOutlet weak var imageViewB2: UIImageView!
    @IBOutlet weak var imageViewB3: UIImageView!
    @IBOutlet weak var imageViewB7: UIImageView!
    @IBOutlet weak var imageViewB8: UIImageView!
    @IBOutlet weak var imageViewB9: UIImageView!
    @IBOutlet weak var imageViewResult: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTransform()
    }
    
    @IBAction func removePicture(_ sender: Any) {
        imageViewB.image = nil
    }
    
    private func startTransform() {
        imageViewB1.image = erodeBWithHoleRing()
        imageViewB2.image = dilateB1WithHoleMask()
        imageViewB3.image = B_or_B2()
        imageViewB7.image = getB7()
        imageViewB8.image = B_and_B7()
        imageViewB9.image = dilateB8WithTipSpacing()
        imageViewResult.image = dilateB7_sub_B9WithDefectCue_or_B9()
    }
    
    private func erodeBWithHoleRing() -> UIImage {
        return OpenCVWrapper.erodeImage(imageViewB.image, withRingOuterRadius: 25, andInnerRadius: 23);
    }
    
    private func dilateB1WithHoleMask() -> UIImage {
        return OpenCVWrapper.dilateImage(imageViewB1.image, withRadius: 23)
    }
    
    private func B_or_B2() -> UIImage {
        return OpenCVWrapper.add(imageViewB.image, to: imageViewB2.image)
    }
    
    private func getB7() -> UIImage {
        return OpenCVWrapper.ring(from: imageViewB3.image, withGearBodyRadius: 60, samplingRingSpacerRadius: 2, andSamplingRingWidthRadius: 3.5)
    }
    
    private func B_and_B7() -> UIImage {
        return OpenCVWrapper.intersectionImage(imageViewB.image, with: imageViewB7.image)
    }
    
    private func dilateB8WithTipSpacing() -> UIImage {
        return OpenCVWrapper.dilateImage(imageViewB8.image, withRadius: 4.5)
    }
    
    private func dilateB7_sub_B9WithDefectCue_or_B9() -> UIImage {
        return OpenCVWrapper.detectDefects(imageViewB9.image, withDefectCueRadius: 10, andMaskImage: imageViewB7.image);
    }
}

