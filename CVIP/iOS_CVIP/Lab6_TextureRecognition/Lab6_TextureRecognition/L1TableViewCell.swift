//
//  L1TableViewCell.swift
//  Lab6_TextureRecognition
//
//  Created by Maxim Aliev on 19/05/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit

class L1TableViewCell: UITableViewCell {

    fileprivate var leftImageFlag = true
    fileprivate var brights1: [Double]?
    fileprivate var brights2: [Double]?
    @IBOutlet private weak var L1Label: UILabel!
    @IBOutlet fileprivate weak var imageView1: UIImageView!
    @IBOutlet fileprivate weak var imageView2: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - private
    
    fileprivate func calcL1() {
        guard let _ = imageView1.image, let _ = imageView2.image,
            let brights1 = brights1,
            let brights2 = brights2 else {
            return
        }
        let L1 = brights1.enumerated().map { abs($1 - brights2[$0]) }.reduce(0, +)
        L1Label.text = Int64(L1).description
    }
}

extension L1TableViewCell: L1TableViewCellProtocol {
    func selectLBPImage(_ image: UIImage, withBrights brights: [Double]) {
        if leftImageFlag {
            imageView1.image = image
            brights1 = brights
        } else {
            imageView2.image = image
            brights2 = brights
        }
        leftImageFlag = !leftImageFlag
        calcL1()
    }
}
