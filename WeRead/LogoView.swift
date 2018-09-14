//
//  LogoView.swift
//  WeRead
//
//  Created by Ian Manor on 12/09/18.
//  Copyright © 2018 Ian. All rights reserved.
//

import UIKit

@IBDesignable
class LogoView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var circleView: UIView!
    
    @IBInspectable
    public var circleColor: UIColor = UIColor(red: 25/255, green: 173/255, blue: 89/255, alpha: 1) {
        didSet {
            return
            //self.circleView.backgroundColor = circleColor
            //setNeedsDisplay()
        }
    }

    /*
#if TARGET_INTERFACE_BUILDER
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        //addSubview(contentView)
    }
#endif
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.circleView.layer.masksToBounds = false
        self.circleView.layer.cornerRadius = circleView.frame.width/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .redraw
        xibSetup()
    }
    
    func xibSetup() {
        let bundle =  Bundle(for: LogoView.self)
        bundle.loadNibNamed("LogoView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
