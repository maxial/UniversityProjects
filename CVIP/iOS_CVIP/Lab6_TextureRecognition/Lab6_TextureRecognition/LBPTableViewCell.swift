//
//  LBPTableViewCell.swift
//  Lab6_TextureRecognition
//
//  Created by Maxim Aliev on 19/05/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit
import Charts

class LBPTableViewCell: UITableViewCell {
    
    var delegate: L1TableViewCellProtocol?
    var imageNames: [String] = [] {
        didSet {
            lbpImages = imageNames.map { lbpImage(from: UIImage(named: $0)!)! }
            collectionView.reloadData()
        }
    }
    fileprivate var lbpImages: [UIImage] = []

    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - private
    
    fileprivate func customize(barChartView: BarChartView) {
        barChartView.noDataText = "Нет данных"
        barChartView.chartDescription?.enabled = false
        barChartView.xAxis.drawLabelsEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.legend.enabled = false
    }
    
    fileprivate func fillChartView(chartView: BarChartView, withValues values: [Double]) {
        var barChartDataEntries = [BarChartDataEntry]()
        for i in 0..<values.count {
            barChartDataEntries.append(BarChartDataEntry(x: Double(i), y: values[i]))
        }
        let barChartDataSet = BarChartDataSet(values: barChartDataEntries, label: nil)
        barChartDataSet.colors = [UIColor.blue]
        chartView.data = BarChartData(dataSet: barChartDataSet)
    }
    
    fileprivate func lbpImage(from image: UIImage) -> UIImage? {
        guard let image = convertToGrayscale(image: image) else {
            return nil
        }
        
        let width = Int(image.size.width), height = Int(image.size.height)
        var lbpPixels = Array(repeating: Pixel(), count: width * height)
        
        if let pixels = image.pixels {
            for i in 1..<height - 1 {
                for j in 1..<width - 1 {
                    let center = pixels[i * width + j].b
                    
                    var code: UInt8 = 0
                    
                    code |= (pixels[(i - 1) * width + j - 1].b > center ? 1 : 0) << 7
                    code |= (pixels[(i - 1) * width + j].b > center ? 1 : 0) << 6
                    code |= (pixels[(i - 1) * width + j + 1].b > center ? 1 : 0) << 5
                    code |= (pixels[i * width + j + 1].b > center ? 1 : 0) << 4
                    code |= (pixels[(i + 1) * width + j + 1].b > center ? 1 : 0) << 3
                    code |= (pixels[(i + 1) * width + j].b > center ? 1 : 0) << 2
                    code |= (pixels[(i + 1) * width + j - 1].b > center ? 1 : 0) << 1
                    code |= (pixels[i * width + j - 1].b > center ? 1 : 0) << 0
                    
                    lbpPixels[i * width + j] = Pixel(a: 255, r: code, g: code, b: code)
                }
            }
        }
        
        return self.imageByPixels(lbpPixels, width: width, height: height)
    }
    
    fileprivate func getBrightsFromImage(_ image: UIImage) -> [Double] {
        var brights: [Double] = Array(repeating: 0, count: 256)
        if let pixels = image.pixels {
            pixels.forEach { brights[Int($0.b)] += 1 }
        }
        return brights
    }
    
    fileprivate func convertToGrayscale(image: UIImage) -> UIImage? {
        if var pixels = image.pixels {
            for i in 0..<pixels.count {
                let gray = UInt8(0.299 * CGFloat(pixels[i].r) + 0.587 * CGFloat(pixels[i].g) + 0.114 * CGFloat(pixels[i].b))
                pixels[i].r = gray; pixels[i].g = gray; pixels[i].b = gray
            }
            return self.imageByPixels(pixels, width: Int(image.size.width), height: Int(image.size.height))
        } else {
            return nil
        }
    }
    
    private func imageByPixels(_ pixels: [Pixel], width: Int, height: Int) -> UIImage? {
        return UIImage.imageFromPixels(pixels: pixels, width: width, height: height)
    }
}

extension LBPTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.className, for: indexPath)
        
        if let image = UIImage(named: imageNames[indexPath.row]) {
            (cell.viewWithTag(1) as! UIImageView).image = image
            
            let histogramView = cell.viewWithTag(2) as! BarChartView
            customize(barChartView: histogramView)
            fillChartView(chartView: histogramView, withValues: getBrightsFromImage(lbpImages[indexPath.row]))
        }
        
        return cell
    }
}

extension LBPTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lbpImage = lbpImages[indexPath.row]
        let brights = getBrightsFromImage(lbpImage)
        delegate?.selectLBPImage(lbpImage, withBrights: brights)
    }
}




