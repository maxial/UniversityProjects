//
//  NSObject+ClassName.swift
//  Lab6_TextureRecognition
//
//  Created by Maxim Aliev on 19/05/17.
//  Copyright © 2017 Maxial. All rights reserved.
//

extension NSObject {
    class var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
