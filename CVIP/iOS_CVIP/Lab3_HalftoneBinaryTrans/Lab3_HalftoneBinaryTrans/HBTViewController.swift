//
//  HBTViewController.swift
//  Lab2_BrightnessTransformations
//
//  Created by Maxim Aliev on 05/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit
import TOCropViewController
import TTRangeSlider

let maxNumberOfQuantLevels = 15
let quantLevelsRGBs = [[0, 0, 255], [0, 64, 255], [0, 128, 255], [0, 192, 255],
                       [0, 255, 255], [0, 255, 192], [0, 255, 128], [0, 255, 64],
                       [0, 255, 0], [64, 255, 0], [128, 255, 0], [192, 255, 0],
                       [255, 255, 0], [255, 192, 0], [255, 128, 0], [255, 0, 0]]

class HBTViewController: UIViewController {
    
    var transType: TransformationType?
    
    @IBOutlet fileprivate weak var initialImageView: UIImageView!
    @IBOutlet fileprivate weak var transImageView: UIImageView!
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rangeSliderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var quantLevelsNum: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quantLevelsNum = 1
        if transType != TransformationType.Manual {
            rangeSliderHeightConstraint.constant = 10
            rangeSlider.isHidden = true
        }
        if transType != TransformationType.QuantizationByBrightness {
            pickerViewHeightConstraint.constant = 0
        }
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
    
    @IBAction func rangeSliderEndDrag(_ sender: TTRangeSlider) {
        startTransformations()
    }
    
    fileprivate func startTransformations() {
        if let transType = transType {
            switch transType {
            case .Manual:                   binarizationManual()
            case .OtsuGlobal:               binarizationOtsu(countOfFragments: 1)
            case .OtsuLocal:                binarizationOtsu(countOfFragments: 16)
            case .OtsuHierarchical:         binarizationOtsuHierarchical2()
            case .QuantizationByBrightness: quantizationByBrightness()
            }
        }
    }
    
    fileprivate func convertToGrayscale(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            if var pixels = image.pixels {
                for i in 0..<pixels.count {
                    let gray = UInt8(0.299 * CGFloat(pixels[i].r) + 0.587 * CGFloat(pixels[i].g) + 0.114 * CGFloat(pixels[i].b))
                    pixels[i].r = gray; pixels[i].g = gray; pixels[i].b = gray
                }
                completion(self.imageByPixels(pixels, width: Int(image.size.width), height: Int(image.size.height)))
            }
        }
    }
    
    private func binarizationManual() {
        if let pixels = initialImageView.image?.pixels {
            DispatchQueue.global(qos: .utility).async { [unowned self] in
                let newPixels: [Pixel] = pixels.map {
                    let bright: UInt8 = self.belongsToRange(n: $0.b) ? 0 : 255
                    return Pixel(a: 255, r: bright, g: bright, b: bright)
                }
                DispatchQueue.main.async { [unowned self] in
                    self.transImageView.image = self.transImageFromPixels(newPixels)
                }
            }
        }
    }
    
    private func belongsToRange(n: UInt8) -> Bool {
        return n >= UInt8(rangeSlider.selectedMinimum) && n <= UInt8(rangeSlider.selectedMaximum)
    }
    
    private func binarizationOtsu(countOfFragments count: Int) {
        if var pixels = initialImageView.image?.pixels {
            DispatchQueue.global(qos: .utility).async { [unowned self] in
                let indexes = self.getIndexes(size: self.initialImageView.image!.size, count: count)
                for i in 0..<count {
                    self.binarizationOtsuForPixels(pixels: &pixels, indexes: indexes[i])
                }
                DispatchQueue.main.async { [unowned self] in
                    self.transImageView.image = self.transImageFromPixels(pixels)
                }
            }
        }
    }
    
    private func binarizationOtsuHierarchical2() {
        if let pixels = initialImageView.image?.pixels {
            var pixelsCopy = pixels
            DispatchQueue.global(qos: .utility).async { [unowned self] in
                self.binarizationOtsuForPixels(pixels: &pixelsCopy, indexes: Array(0..<pixels.count))
                DispatchQueue.main.async { [unowned self] in
                    self.transImageView.image = self.transImageFromPixels(pixelsCopy)
                }
                for _ in 0..<10 {
                    var indexes = self.getWBIndexes(pixels: pixelsCopy)
                    print(indexes[0].count)
                    print(indexes[1].count)
                    pixelsCopy = pixels
                    self.binarizationOtsuForPixels(pixels: &pixelsCopy, indexes: indexes[0])
                    self.binarizationOtsuForPixels(pixels: &pixelsCopy, indexes: indexes[1])
                    DispatchQueue.main.async { [unowned self] in
                        self.transImageView.image = self.transImageFromPixels(pixelsCopy)
                    }
                    sleep(1)
                }
            }
        }
    }
    
    private func binarizationOtsuForPixels(pixels: inout [Pixel], indexes: [Int]) {
        let brights = self.getBrightsFromPixels(pixels, indexes: indexes)
        let pixelsCount = indexes.count
        let ps = brights.map { $0 / Double(pixelsCount) }
        var mG = 0.0
        for i in 0..<ps.count { mG += Double(i) * ps[i] }
        
        let kOpt = self.maximizeInterclassDispersion(mG: mG, ps: ps)
        
        indexes.forEach {
            let bright: UInt8 = kOpt < pixels[$0].b ? 255 : 0
            pixels[$0] = Pixel(a: 255, r: bright, g: bright, b: bright)
        }
    }
    
//    private func binarizationOtsuHierarchicalAlgo(pixels: [Pixel], pixelsCopy: inout [Pixel]) {
//        var indexes = self.getWBIndexes(pixels: pixelsCopy)
//        var mutablePixels = pixels
//        indexes = self.getWBIndexes(pixels: mutablePixels)
//        for i in 0..<indexes.count {
//            self.binarizationOtsuForPixels(pixels: &mutablePixels, indexes: indexes[i])
//            DispatchQueue.main.async { [unowned self] in
//                self.transImageView.image = self.transImageFromPixels(pixels)
//            }
//            sleep(1)
//            indexes = self.getWBIndexes(pixels: mutablePixels)
//            mutablePixels = pixels
//        }
//        
//        
//        
//    }
    
    private func binarizationOtsuHierarchical() {
        var count = 1, max = Int(pow(4.0, 7.0))
        while count <= max {
            binarizationOtsu(countOfFragments: count)
            sleep(1)
            count *= 4
        }
    }
    
    private func quantizationByBrightness() {
        if var pixels = initialImageView.image?.pixels {
            let brights = self.getBrightsFromPixels(pixels, indexes: Array(0..<pixels.count))
            var bordersBrights = [UInt8]()
            let step: UInt8 = UInt8(brights.count / (quantLevelsNum + 1))
            for i in 1...quantLevelsNum {
                bordersBrights.append(UInt8(i) * step)
            }
            pixels = pixels.map {
                let rgb = self.getRGBForBright($0.b, bordersBrights: bordersBrights)
                return Pixel(a: 255, r: UInt8(rgb[0]), g: UInt8(rgb[1]), b: UInt8(rgb[2]))
            }
            DispatchQueue.main.async { [unowned self] in
                self.transImageView.image = self.transImageFromPixels(pixels)
            }
        }
    }
    
    private func getRGBForBright(_ bright: UInt8, bordersBrights: [UInt8]) -> [Int] {
        for i in 0..<bordersBrights.count {
            if bright < bordersBrights[i] {
                return quantLevelsRGBs[i]
            }
        }
        return quantLevelsRGBs[quantLevelsNum]
    }
    
    private func maximizeInterclassDispersion(mG: Double, ps: [Double]) -> UInt8 {
        var k = 0, max = 0.0
        for i in 1..<ps.count {
            var mk = 0.0
            for j in 0...i { mk += Double(j) * ps[j] }
            let pC1 = ps.dropLast(ps.count - i).reduce(0, +)
            
            if (pC1 > 0) {
                let value = pow(mG * pC1 - mk, 2) / (pC1 * (1 - pC1))
                if value > max {
                    max = value
                    k = i
                }
            }
        }
        return UInt8(k)
    }
    
    private func getIndexes(size: CGSize, count: Int) -> [[Int]] {
        let partsInStrip: Int = Int(sqrt(Double(count)))
        let width: Int = Int(size.width) / partsInStrip
        let height: Int = Int(size.height) / partsInStrip
        var indexes = Array(repeating: [Int](), count: count)
        for i in 0..<count {
            for j in 0..<height {
                let row = i / partsInStrip * height + j
                for k in 0..<width {
                    let col = i % partsInStrip * width + k
                    indexes[i].append(row * Int(size.width) + col)
                }
            }
        }
        return indexes
    }
    
    private func getWBIndexes(pixels: [Pixel]) -> [[Int]] {
        var indexes = Array(repeating: [Int](), count: 2)
        
        for i in 0..<pixels.count {
            let indexClass = pixels[i].b == 255 ? 0 : 1
            indexes[indexClass].append(i)
        }
        
        return indexes
    }
    
    private func getBrightsFromImage(_ image: UIImage, indexes: [Int]) -> [Double] {
        return getBrightsFromPixels(image.pixels, indexes: indexes)
    }
    
    private func getBrightsFromPixels(_ pixels: [Pixel]?, indexes: [Int]) -> [Double] {
        var brights: [Double] = Array(repeating: 0, count: 256)
        if pixels != nil {
            indexes.forEach { brights[Int(pixels![$0].b)] += 1 }
        }
        return brights
    }
    
    private func transImageFromPixels(_ pixels: [Pixel]) -> UIImage? {
        return imageByPixels(pixels, width: Int(initialImageView.image!.size.width), height: Int(initialImageView.image!.size.height))
    }
    
    private func imageByPixels(_ pixels: [Pixel], width: Int, height: Int) -> UIImage? {
        return UIImage.imageFromPixels(pixels: pixels, width: width, height: height)
    }
    
    fileprivate func setConstraints(imageSize: CGSize) {
        let aspectRatio = imageSize.width / imageSize.height
        imageViewHeightConstraint.constant = initialImageView.frame.width / aspectRatio
    }
}

extension HBTViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        convertToGrayscale(image: info[UIImagePickerControllerOriginalImage] as! UIImage) { [unowned self] in
            self.initialImageView.image = $0
            self.setConstraints(imageSize: $0!.size)
            self.startTransformations()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension HBTViewController: TOCropViewControllerDelegate {
    @objc(cropViewController:didCropToImage:withRect:angle:)
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        setConstraints(imageSize: image.size)
        initialImageView.image = image
        startTransformations()
        
        dismiss(animated: true, completion: nil)
    }
}

extension HBTViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxNumberOfQuantLevels
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (row + 1).description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        quantLevelsNum = row + 1
        startTransformations()
    }
}




