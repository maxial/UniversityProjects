//
//  RGBHistViewController.swift
//  Lab1-rgbHistogram
//
//  Created by Maxim Aliev on 05/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit
import Charts
import TOCropViewController

class RGBHistViewController: UIViewController {
    
    @IBOutlet fileprivate var chartViews: [BarChartView]!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    
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
        if imageView.image != nil {
            setConstraints(imageSize: imageView.image!.size)
        }
    }
    
    @IBAction func loadPicture(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionSheetController = createActionSheetControllerForImagePicker(imagePicker)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func removePicture(_ sender: Any) {
        imageView.image = nil
        updateHistogram()
    }
    
    @IBAction func selectAreaOfImage(_ sender: Any) {
        guard let image = imageView.image else {
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
    
    private func customizeCharts() {
        let colors = [UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.05),
                      UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.05),
                      UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.05)]
        for i in 0..<chartViews.count {
            let chartView = chartViews[i]
            chartView.backgroundColor = colors[i]
            chartView.noDataText = "Нет данных"
            chartView.chartDescription?.enabled = false
            chartView.xAxis.drawLabelsEnabled = false
            chartView.leftAxis.drawLabelsEnabled = false
            chartView.rightAxis.drawLabelsEnabled = false
            chartView.legend.enabled = false
        }
    }
    
    fileprivate func updateHistogram() {
        guard let _ = imageView.image else {
            clearChartViews()
            return
        }
        let colors = [UIColor.red, UIColor.green, UIColor.blue], labels = ["R", "G", "B"]
        var RGB: [[Double]] = Array(repeating: Array(repeating: 0, count: 256), count: 3)
        getRGBData(&RGB)
        
        for i in 0..<RGB.count {
            let max = RGB[i].max()!
            RGB[i] = RGB[i].map { $0 / max }
            
            var barChartDataEntries = [BarChartDataEntry]()
            for j in 0..<RGB[i].count {
                barChartDataEntries.append(BarChartDataEntry(x: Double(j), y: RGB[i][j]))
            }
            let barChartDataSet = BarChartDataSet(values: barChartDataEntries, label: labels[i])
            barChartDataSet.colors = [colors[i]]
            chartViews[i].data = BarChartData(dataSet: barChartDataSet)
        }
    }
    
    private func getRGBData(_ RGB: inout [[Double]]) {
        guard let pixelsData = imageView.image?.cgImage?.dataProvider?.data else {
            return
        }
        let data = CFDataGetBytePtr(pixelsData)!
        
        let width = Int(imageView.image!.size.width), height = Int(imageView.image!.size.height)
        for y in 0..<height {
            let verticalOffset = width * y
            for x in 0..<width {
                let pixelData = (verticalOffset + x) * 4
                RGB[0][Int(data[pixelData])] += 1
                RGB[1][Int(data[pixelData + 1])] += 1
                RGB[2][Int(data[pixelData + 2])] += 1
            }
        }
    }
    
    private func clearChartViews() {
        for chartView in chartViews {
            chartView.clear()
        }
    }
    
    fileprivate func setConstraints(imageSize: CGSize) {
        let aspectRatio = imageSize.width / imageSize.height
        imageViewHeightConstraint.constant = imageView.frame.width / aspectRatio
    }
}

extension RGBHistViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        setConstraints(imageSize: image.size)
        imageView.image = image
        dismiss(animated: true, completion: nil)
        
        updateHistogram()
    }
}

extension RGBHistViewController: TOCropViewControllerDelegate {
    @objc(cropViewController:didCropToImage:withRect:angle:)
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        setConstraints(imageSize: image.size)
        imageView.image = image
        dismiss(animated: true, completion: nil)
        
        updateHistogram()
    }
}





