//
//  Line.swift
//  HammockUP
//
//  Created by Anthony Guillard on 24/04/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit

class Line: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }

     */

    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1).setStroke()
        path.stroke()
    }
}
