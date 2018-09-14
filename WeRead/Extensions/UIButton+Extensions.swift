//
//  UIButton+Extensions.swift
//  WeRead
//
//  Created by Ian Manor on 13/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    @IBInspectable var adjustFontSizeToWidth: Bool {
        get {
            return self.titleLabel?.adjustsFontSizeToFitWidth ?? false
        }
        set {
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.adjustsFontSizeToFitWidth = newValue;
            self.titleLabel?.lineBreakMode = .byClipping;
            self.titleLabel?.baselineAdjustment = .alignCenters
        }
    }
}
