//
//  HistBTViewController.swift
//  Lab2_BrightnessTransformations
//
//  Created by Maxim Aliev on 23/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit
import TOCropViewController
import Charts

class HistBTViewController: UIViewController {
    
    var transType: TransformationType?
    
    @IBOutlet private weak var transTypeLabel: UILabel!
    
    @IBOutlet fileprivate weak var initialImageView: UIImageView!
    @IBOutlet fileprivate weak var transImageView: UIImageView!
    @IBOutlet private weak var initialChartView: BarChartView!
    @IBOutlet private weak var transChartView: BarChartView!
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeCharts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func rotated() {
        if initialImageView.image != nil {
            setConstraints(imageSize: initialImageView.image!.size)
        }
    }
    
    private func customizeCharts() {
        initialChartView.noDataText = "Нет данных"
        initialChartView.chartDescription?.enabled = false
        initialChartView.xAxis.drawLabelsEnabled = false
        initialChartView.leftAxis.drawLabelsEnabled = false
        initialChartView.rightAxis.drawLabelsEnabled = false
        initialChartView.legend.enabled = false
        transChartView.noDataText = "Нет данных"
        transChartView.chartDescription?.enabled = false
        transChartView.xAxis.drawLabelsEnabled = false
        transChartView.leftAxis.drawLabelsEnabled = false
        transChartView.rightAxis.drawLabelsEnabled = false
        transChartView.legend.enabled = false
    }
    
    @IBAction func loadPicture(_ sender: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionSheetController = createActionSheetControllerForImagePicker(imagePicker)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func removePicture(_ sender: Any) {
        initialImageView.image = nil
        transImageView.image = nil
    }
    
    @IBAction func selectAreaOfImage(_ sender: Any) {
        guard let image = initialImageView.image else {
            let alertController = UIAlertController(title: "Пожалуйста, загрузите изображение", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    private func createActionSheetControllerForImagePicker(_ imagePicker: UIImagePickerController) -> UIAlertController {
        let actionSheetController = UIAlertController(title: "Выберите способ", message: nil, preferredStyle: .actionSheet)
        let cameraSourceAction = UIAlertAction(title: "Камера", style: .default) { [unowned self] (_) in
            imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let photoLibrarySourceAction = UIAlertAction(title: "Сохраненные фото", style: .default) { [unowned self] (_) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(cameraSourceAction)
        actionSheetController.addAction(photoLibrarySourceAction)
        actionSheetController.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        return actionSheetController
    }
    
    fileprivate func startTransformations() {
//        convertToGrayscale(imageView: initialImageView)
        guard let initialImage = initialImageView.image else {
            clearChartViews()
            return
        }
        let brights = getBrightsFromImage(initialImage)
        fillChartView(chartView: initialChartView, withValues: brights)
        
        if let transType = transType {
            if (transType == .NormalizationHist) {
                normalization(brights: brights)
            } else {
                equalization(brights: brights)
            }
        }
    }
    
    private func convertToGrayscale(imageView: UIImageView) {
        if let image = imageView.image {
            DispatchQueue.global(qos: .utility).async { [unowned self] in
                if var pixels = image.pixels {
                    for i in 0..<pixels.count {
                        let gray = UInt8(0.299 * CGFloat(pixels[i].r) + 0.587 * CGFloat(pixels[i].g) + 0.114 * CGFloat(pixels[i].b))
                        pixels[i].r = gray; pixels[i].g = gray; pixels[i].b = gray
                    }
                    self.imageByPixels(pixels: pixels, imageView: self.initialImageView, chart: self.initialChartView)
                }
            }
        }
    }
    
    fileprivate func equalization(brights: [Double]) {
        histEqualization(brights: brights) { [unowned self] transFuncValues in
            self.imageByTransFuncValues(transFuncValues)
        }
    }
    
    fileprivate func normalization(brights: [Double]) {
        histNormalization(brights: brights)
    }
    
    private func getBrightsFromImage(_ image: UIImage) -> [Double] {
        var brights: [Double] = Array(repeating: 0, count: 256)
        if let pixels = image.pixels {
            pixels.forEach { brights[Int($0.b)] += 1 }
        }
        return brights
    }
    
    private func histEqualization(brights: [Double], completion: @escaping ([Double]) -> Void) {
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            if let image = self.initialImageView.image {
                let numOfPixels = image.size.width * image.size.height
                var transFuncValues = brights.map { $0 / Double(numOfPixels) }
                for i in 1..<transFuncValues.count {
                    transFuncValues[i] += transFuncValues[i - 1]
                }
                completion(transFuncValues)
            }
        }
    }
    
    private func histNormalization(brights: [Double]) {
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            let Imin = brights.index { $0 > 0 } ?? 1
            var Imax = brights.count
            if brights.last! == 0 {
                for i in (0..<brights.count).reversed() {
                    if brights[i] == 0 {
                        Imax = i
                        break
                    }
                }
            }
            if let image = self.initialImageView.image {
                if var pixels = image.pixels {
                    pixels = pixels.map {
                        let bright = CGFloat(Double(Int($0.b) - Imin) / Double(Imax - Imin))
                        return Pixel(a: CGFloat($0.a) / 255.0, r: bright, g: bright, b: bright)
                    }
                    self.imageByPixels(pixels: pixels, imageView: self.transImageView, chart: self.transChartView)
                }
            }
        }
    }
    
    private func imageByTransFuncValues(_ transFuncValues: [Double]) {
        if let image = initialImageView.image {
            if var pixels = image.pixels {
                for i in 0..<pixels.count {
                    let bright = Int(pixels[i].b)
                    let newBright = UInt8(transFuncValues[bright] * 255.0)
                    pixels[i].r = newBright; pixels[i].g = newBright; pixels[i].b = newBright
                }
                imageByPixels(pixels: pixels, imageView: transImageView, chart: transChartView)
            }
        }
    }
    
    private func imageByPixels(pixels: [Pixel], imageView: UIImageView, chart: BarChartView) {
        let width = Int(initialImageView.image!.size.width)
        let height = Int(initialImageView.image!.size.height)
        let transImage = UIImage.imageFromPixels(pixels: pixels, width: width, height: height)
        DispatchQueue.main.async { [unowned self] in
            if let transImage = transImage {
                imageView.image = transImage
                let brights = self.getBrightsFromImage(transImage)
                self.fillChartView(chartView: chart, withValues: brights)
            }
        }
    }
    
    private func fillChartView(chartView: BarChartView, withValues values: [Double]) {
        var barChartDataEntries = [BarChartDataEntry]()
        for i in 0..<values.count {
            barChartDataEntries.append(BarChartDataEntry(x: Double(i), y: values[i]))
        }
        let barChartDataSet = BarChartDataSet(values: barChartDataEntries, label: nil)
        barChartDataSet.colors = [UIColor.black]
        chartView.data = BarChartData(dataSet: barChartDataSet)
    }
    
    private func clearChartViews() {
        initialChartView.clear()
        transChartView.clear()
    }
    
    fileprivate func setConstraints(imageSize: CGSize) {
        let aspectRatio = imageSize.width / imageSize.height
        imageViewHeightConstraint.constant = initialImageView.frame.width / aspectRatio
    }
}

extension HistBTViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        setConstraints(imageSize: image.size)
        initialImageView.image = image
        startTransformations()
        
        dismiss(animated: true, completion: nil)
    }
}

extension HistBTViewController: TOCropViewControllerDelegate {
    @objc(cropViewController:didCropToImage:withRect:angle:)
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        setConstraints(imageSize: image.size)
        initialImageView.image = image
        startTransformations()
        
        dismiss(animated: true, completion: nil)
    }
}



