//
//  UIImage+PixelsData.swift
//  Lab1-rgbHistogram
//
//  Created by Maxim Aliev on 08/03/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit

private let BYTES_PER_PIXEL: Int = 4

struct Pixel {
    var a: UInt8 = 0
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
    
    init() {
        self.a = 0
        self.r = 0
        self.g = 0
        self.b = 0
    }
    
    init(a: UInt8, r: UInt8, g: UInt8, b: UInt8) {
        self.a = a
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(a: CGFloat, r: CGFloat, g: CGFloat, b: CGFloat) {
        self.a = a < 0.0 ? 0 : a > 1.0 ? 255 : UInt8(a * 255)
        self.r = r < 0.0 ? 0 : r > 1.0 ? 255 : UInt8(r * 255)
        self.g = g < 0.0 ? 0 : g > 1.0 ? 255 : UInt8(g * 255)
        self.b = b < 0.0 ? 0 : b > 1.0 ? 255 : UInt8(b * 255)
    }
}

extension UIImage {
    
    var pixels: [Pixel]? {
        guard let providerData = self.cgImage?.dataProvider?.data else {
            return nil
        }
        let data = CFDataGetBytePtr(providerData)!
        
        let size = Int(self.size.width * self.size.height)
        var pixels: [Pixel] = Array(repeating: Pixel(), count: size)
        for i in 0..<size {
            let pxl = i * BYTES_PER_PIXEL
            pixels[i].r = UInt8(data[pxl])
            pixels[i].g = UInt8(data[pxl + 1])
            pixels[i].b = UInt8(data[pxl + 2])
            pixels[i].a = UInt8(data[pxl + 3])
        }
        return pixels
    }
    
    var pixelsPremultipliedLast: [Pixel]? {
        guard let providerData = self.cgImage?.dataProvider?.data else {
            return nil
        }
        let data = CFDataGetBytePtr(providerData)!
        
        let size = Int(self.size.width * self.size.height)
        var pixels: [Pixel] = Array(repeating: Pixel(), count: size)
        for i in 0..<size {
            let pxl = i * BYTES_PER_PIXEL
            pixels[i].a = UInt8(data[pxl + 3])
            pixels[i].r = UInt8(data[pxl + 2])
            pixels[i].g = UInt8(data[pxl + 1])
            pixels[i].b = UInt8(data[pxl])
        }
        return pixels
    }
    
    func colorForPixel(x: Int, y: Int) -> UIColor? {
        guard let providerData = self.cgImage?.dataProvider?.data else {
            return nil
        }
        let data = CFDataGetBytePtr(providerData)!
        let i = (y * Int(self.size.width) + x) * 4;
        return UIColor(red: CGFloat(data[i]) / 255.0,
                       green: CGFloat(data[i + 1]) / 255.0,
                       blue: CGFloat(data[i + 2]) / 255.0,
                       alpha: CGFloat(data[i + 3]) / 255.0)
    }
    
    class func imageFromPixels(pixels: [Pixel], width: Int, height: Int) -> UIImage? {
        var pixelsCopy = pixels
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let data = NSData(bytes: &pixelsCopy, length: pixelsCopy.count * MemoryLayout<Pixel>.size)
        if let provider = CGDataProvider(data: data) {
            if let cgImage = CGImage(width: width,
                                     height: height,
                                     bitsPerComponent: 8,
                                     bitsPerPixel: 8 * BYTES_PER_PIXEL,
                                     bytesPerRow: width * MemoryLayout<Pixel>.size,
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo,
                                     provider: provider,
                                     decode: nil,
                                     shouldInterpolate: true,
                                     intent: CGColorRenderingIntent.defaultIntent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}




