//
//  BTViewController.swift
//  Lab2_BrightnessTransformations
//
//  Created by Maxim Aliev on 05/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit
import TOCropViewController
import DRColorPicker

fileprivate let transFuncsNames = ["id", "neg", "c*ln(1+x)", "c*x^n"]

private typealias TransFunc = (_ x: CGFloat, _ c: CGFloat, _ n: CGFloat) -> CGFloat
fileprivate let transFuncs: [TransFunc] = [{ (x, _, _) in return x },
                                           { (x, _, _) in return 1.0 - x },
                                           { (x, c, _) in return c * log(1.0 + x) },
                                           { (x, c, n) in return c * pow(x, n) }]

class BTViewController: UIViewController {
    
    var transType: TransformationType?
    
    @IBOutlet fileprivate weak var initialImageView: UIImageView!
    @IBOutlet fileprivate weak var transImageView: UIImageView!
    
    @IBOutlet private weak var transFuncPickerView: UIPickerView!
    @IBOutlet private weak var srcColorView: UIView!
    @IBOutlet private weak var destColorView: UIView!
    
    @IBOutlet fileprivate weak var cSlider: UISlider!
    @IBOutlet fileprivate weak var nSlider: UISlider!
    @IBOutlet fileprivate weak var cLabel: UILabel!
    @IBOutlet fileprivate weak var nLabel: UILabel!
    
    @IBOutlet private weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var baseColorPanelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var transFuncPanelHeightConstraint: NSLayoutConstraint!
    
    private var touchToggle: Bool!
    private var srcColor: UIColor? {
        didSet { srcColorView.backgroundColor = srcColor }
    }
    private var destColor: UIColor? {
        didSet { destColorView.backgroundColor = destColor }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touchToggle = false
        transFuncPickerView.selectRow(0, inComponent: 0, animated: false)
        if transType != TransformationType.BaseColor {
            hidePanelBasedOnHeightConstraint(baseColorPanelHeightConstraint)
        }
        if transType != TransformationType.TransFunc {
            hidePanelBasedOnHeightConstraint(transFuncPanelHeightConstraint)
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
    
    private func hidePanelBasedOnHeightConstraint(_ constraint: NSLayoutConstraint) {
        constraint.constant = 0.0
        if let view = constraint.firstItem as? UIView {
            view.isHidden = true
        }
    }
    
    @IBAction func loadPicture(_ sender: UITapGestureRecognizer) {
        if (TransformationType.BaseColor != transType || sender.view === initialImageView && nil == initialImageView.image) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            let actionSheetController = createActionSheetControllerForImagePicker(imagePicker)
            self.present(actionSheetController, animated: true, completion: nil)
        } else {
            let point = sender.location(in: sender.view)
            let x = initialImageView.image!.size.width / initialImageView.frame.size.width * point.x
            let y = initialImageView.image!.size.height / initialImageView.frame.size.height * point.y
            if (sender.view === initialImageView) {
                if let image = initialImageView.image {
                    if (false == touchToggle) {
                        srcColor = image.colorForPixel(x: Int(x), y: Int(y))
                    } else {
                        destColor = image.colorForPixel(x: Int(x), y: Int(y))
                    }
                    touchToggle = !touchToggle
                }
            }
            baseColorTransform()
        }
    }
    
    @IBAction func removePicture(_ sender: Any) {
        initialImageView.image = nil
        transImageView.image = nil
        srcColor = UIColor.clear
        destColor = UIColor.clear
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
    
//    @IBAction func chooseBaseColor(_ sender: Any) {
//        configureDRColorPicker { [unowned self] (color, vc) -> Void in
//            self.destColor = color
//            self.startTransformations()
//        }
//    }
    
    @IBAction func parameterSliderValueChanged(_ sender: UISlider) {
        if sender == cSlider {
            cLabel.text = "c = \(String(format: "%.2f", cSlider.value))"
        }
        if sender == nSlider {
            nLabel.text = "n = \(String(format: "%.2f", nSlider.value))"
        }
    }
    
    @IBAction func parameterSliderEndDrag(_ sender: Any) {
        transFuncTransform()
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
    
//    private func configureDRColorPicker(colorSelectedBlock: @escaping (DRColorPickerColor?, DRColorPickerBaseViewController?) -> Void) {
//        DRColorPickerBackgroundColor = UIColor.white
//        DRColorPickerBorderColor = UIColor.black
//        DRColorPickerFont = UIFont.systemFont(ofSize: 17.0)
//        DRColorPickerLabelColor = UIColor.black
//        DRColorPickerShowSaturationBar = true
//        DRColorPickerHighlightLastHue = true
//        
//        if destColor == nil {
//            destColor = DRColorPickerColor(color: defaultBaseColor)
//        }
//        let vc = DRColorPickerViewController.newColorPicker(with: destColor)!
//        vc.modalPresentationStyle = .formSheet
//        vc.rootViewController.showAlphaSlider = true
//        vc.rootViewController.dismissBlock = { [unowned self] (cancel) -> Void in
//            self.dismiss(animated: true, completion: nil)
//        }
//        vc.rootViewController.colorSelectedBlock = colorSelectedBlock
//        self.present(vc, animated: true, completion: nil)
//    }
    
    fileprivate func startTransformations() {
        if let transType = transType {
            switch transType {
            case .BaseColor: baseColorTransform()
            case .GrayWorld: grayWorldTransform()
            case .TransFunc: transFuncTransform()
            default: break
            }
        }
    }
    
    fileprivate func baseColorTransform() {
//        transformImage {
//            return Pixel(a: CGFloat($0.a) / 255.0, r: CGFloat($0.r) / 255.0 * 1.1, g: CGFloat($0.g) * 0.9 / 255.0, b: CGFloat($0.b) * 1.15 / 255.0)
//        }
        
        if let srcColor = srcColor, let destColor = destColor {
            transformImage { (pixel) -> Pixel in
                var rS: CGFloat = 0.0, gS: CGFloat = 0.0, bS: CGFloat = 0.0, aS: CGFloat = 0.0
                srcColor.getRed(&rS, green: &gS, blue: &bS, alpha: &aS)
                var rD: CGFloat = 0.0, gD: CGFloat = 0.0, bD: CGFloat = 0.0, aD: CGFloat = 0.0
                destColor.getRed(&rD, green: &gD, blue: &bD, alpha: &aD)
                var r: CGFloat = CGFloat(pixel.r) / 255.0
                var g: CGFloat = CGFloat(pixel.g) / 255.0
                var b: CGFloat = CGFloat(pixel.b) / 255.0
                r = rS == 0.0 ? rD == 0.0 ? 0.0 : 1.0 : r * rD / rS
                g = gS == 0.0 ? gD == 0.0 ? 0.0 : 1.0 : g * gD / gS
                b = bS == 0.0 ? bD == 0.0 ? 0.0 : 1.0 : b * bD / bS
                return Pixel(a: CGFloat(pixel.a) / 255.0, r: r, g: g, b: b)
            }
        }
    }
    
    private func grayWorldTransform() {
        var avgR: CGFloat = 0.0, avgG: CGFloat = 0.0, avgB: CGFloat = 0.0, avgRGB: CGFloat = 0.0
        avgBrightness(avgR: &avgR, avgG: &avgG, avgB: &avgB, avgRGB: &avgRGB)
        let rFactor = avgRGB / avgR, gFactor = avgRGB / avgG, bFactor = avgRGB / avgB
        
        transformImage {
            return Pixel(a: CGFloat($0.a) / 255.0,
                         r: CGFloat($0.r) / 255.0 * rFactor,
                         g: CGFloat($0.g) / 255.0 * gFactor,
                         b: CGFloat($0.b) / 255.0 * bFactor)
        }
    }
    
    fileprivate func transFuncTransform() {
        let f = transFuncs[transFuncPickerView.selectedRow(inComponent: 0)]
        let c = CGFloat(cSlider.value), n = CGFloat(nSlider.value)
        
        transformImage {
            return Pixel(a: CGFloat($0.a) / 255.0,
                         r: f(CGFloat($0.r) / 255.0, c, n),
                         g: f(CGFloat($0.g) / 255.0, c, n),
                         b: f(CGFloat($0.b) / 255.0, c, n))
        }
    }
    
    private func createBadImageFromImage(image: UIImage?) {
        if let image = image {
            if let pixels = image.pixels {
                imageByPixels(pixels: pixels, imageView: transImageView)
            }
        }
    }
    
    private func imageByPixels(pixels: [Pixel], imageView: UIImageView) {
        let width = Int(initialImageView.image!.size.width)
        let height = Int(initialImageView.image!.size.height)
        let transImage = UIImage.imageFromPixels(pixels: pixels, width: width, height: height)
        DispatchQueue.main.async {
            if let transImage = transImage {
                imageView.image = transImage
            }
        }
    }
    
    private func transformImage(pixelFunc: @escaping (_ pixel: Pixel) -> Pixel) {
        if let image = initialImageView.image {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicator.center = CGPoint(x: transImageView.bounds.width / 2, y: 50)
            transImageView.addSubview(activityIndicator)
            DispatchQueue.global(qos: .utility).async { [unowned self] in
                activityIndicator.startAnimating()
                
                self.cSlider.isUserInteractionEnabled = false
                self.nSlider.isUserInteractionEnabled = false
                
                let pixels = image.pixels!.map { pixelFunc($0) }
                let transImage = UIImage.imageFromPixels(pixels: pixels,
                                                         width: Int(image.size.width),
                                                         height: Int(image.size.height))
                DispatchQueue.main.async { [unowned self] in
                    self.cSlider.isUserInteractionEnabled = true
                    self.nSlider.isUserInteractionEnabled = true
                    self.transImageView.image = transImage
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }
        }
    }
    
    private func avgBrightness(avgR: inout CGFloat, avgG: inout CGFloat, avgB: inout CGFloat, avgRGB: inout CGFloat) {
        avgR = 0.0; avgG = 0.0; avgB = 0.0
        
        if let image = initialImageView.image {
            if let pixels = image.pixels {
                for pixel in pixels {
                    avgR += CGFloat(pixel.r) / 255.0
                    avgG += CGFloat(pixel.g) / 255.0
                    avgB += CGFloat(pixel.b) / 255.0
                }
            }
            let size = Int(image.size.width) * Int(image.size.height)
            avgR /= CGFloat(size)
            avgG /= CGFloat(size)
            avgB /= CGFloat(size)
            avgRGB = (avgR + avgG + avgB) / 3.0
        }
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let width = min(UIScreen.main.bounds.height, image.size.height)
//        let width = image.size.width
        let size = CGSize(width: width, height: width * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    fileprivate func setConstraints(imageSize: CGSize) {
        let aspectRatio = imageSize.width / imageSize.height
        imageViewHeightConstraint.constant = initialImageView.frame.width / aspectRatio
    }
}

extension BTViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        setConstraints(imageSize: image.size)
        initialImageView.image = image
        startTransformations()
        
        dismiss(animated: true, completion: nil)
    }
}

extension BTViewController: TOCropViewControllerDelegate {
    @objc(cropViewController:didCropToImage:withRect:angle:)
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        setConstraints(imageSize: image.size)
        initialImageView.image = image
        startTransformations()
        
        dismiss(animated: true, completion: nil)
    }
}

extension BTViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return transFuncsNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return transFuncsNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        startTransformations()
        cSlider.isHidden = row < 2
        nSlider.isHidden = row < 3
        cLabel.isHidden = row < 2
        nLabel.isHidden = row < 3
    }
}




