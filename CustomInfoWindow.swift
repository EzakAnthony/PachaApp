//
//  CustomInfoWindow.swift
//  HammockUP
//
//  Created by Anthony Guillard on 14/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import Foundation

class CustomInfoWindow: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadView() -> CustomInfoWindow{
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        return customInfoWindow
    }

    //Outlets
    @IBOutlet weak var labelInfoWindow: UILabel!
    
}
