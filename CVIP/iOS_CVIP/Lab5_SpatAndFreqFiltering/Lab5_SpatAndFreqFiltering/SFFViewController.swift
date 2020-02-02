//
//  SFFViewController.swift
//  Lab5_SpatAndFreqFiltering
//
//  Created by Maxim Aliev on 11/04/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit

class SFFViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var spectrumImageView: UIImageView!
    @IBOutlet private weak var smoothingFilterImageView: UIImageView!
    @IBOutlet private weak var smoothingResultSpectrumImageView: UIImageView!
    @IBOutlet private weak var smoothingResultImageView: UIImageView!
    @IBOutlet private weak var sharpnessFilterImageView: UIImageView!
    @IBOutlet private weak var sharpnessResultSpectrumImageView: UIImageView!
    @IBOutlet private weak var sharpnessResultImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTransform()
    }
    
    private func startTransform() {
        spectrumImageView.image = imageSpectrum()
        smoothingFilterImageView.image = smoothingFilterImageSpectrum()
        smoothingResultImageView.image = smoothingResultImage()
        smoothingResultSpectrumImageView.image = smoothingResultImageSpectrum()
        sharpnessFilterImageView.image = sharpnessFilterImageSpectrum()
        sharpnessResultImageView.image = sharpnessResultImage()
        sharpnessResultSpectrumImageView.image = sharpnessResultImageSpectrum()
    }
    
    private func imageSpectrum() -> UIImage {
        return OpenCVWrapper.spectrumImage(from: imageView.image)
    }
    
    private func smoothingFilterImageSpectrum() -> UIImage {
        return OpenCVWrapper.spectrumImageFromGaussianFilter(with: CGSize(width: imageView.image!.size.width, height: imageView.image!.size.height), cutoffInPixels: 20.0, type: LowFreq)
    }
    
    private func smoothingResultImage() -> UIImage {
        return OpenCVWrapper.applyFilterImage(smoothingFilterImageView.image, to: imageView.image)
    }
    
    private func smoothingResultImageSpectrum() -> UIImage {
        return OpenCVWrapper.spectrumImage(from: smoothingResultImageView.image)
    }
    
    private func sharpnessFilterImageSpectrum() -> UIImage {
        return OpenCVWrapper.spectrumImageFromGaussianFilter(with: CGSize(width: imageView.image!.size.width, height: imageView.image!.size.height), cutoffInPixels: 10.0, type: HighFreq)
    }
    
    private func sharpnessResultImage() -> UIImage {
        return OpenCVWrapper.applyFilterImage(sharpnessFilterImageView.image, to: imageView.image)
    }
    
    private func sharpnessResultImageSpectrum() -> UIImage {
        return OpenCVWrapper.spectrumImage(from: sharpnessResultImageView.image)
    }
}

