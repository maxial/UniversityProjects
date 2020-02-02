//
//  HLViewController.swift
//  Project2_HoughLines
//
//  Created by Maxim Aliev on 18/05/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

import UIKit

class HLViewController: UIViewController {
    
    @IBOutlet private weak var initialImageView: UIImageView!
    @IBOutlet private weak var resultImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        transform()
    }
    
    // MARK: - private
    
    private func transform() {
        resultImageView.image = OpenCVWrapper.houghTransformLines(to: initialImageView.image!)
    }
}

