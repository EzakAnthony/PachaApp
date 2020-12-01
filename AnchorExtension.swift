//
//  AnchorExtension.swift
//  HammockUP
//
//  Created by Anthony Guillard on 09/04/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
 
    func anchor (top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {

        //remove autolayout
        translatesAutoresizingMaskIntoConstraints = false
        /*
        if #available(iOS 11, *), enableInsets {
            let insets = self.safeAreaInsets
            topInset = insets.top
            bottomInset = insets.bottom
     
            print("Top: \(topInset)")
            print("bottom: \(bottomInset)")
        }
 */
     
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if size.height != 0 {
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
        if size.width != 0 {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
     
    }
    
    //remove anchor for display changing
    func deActiveAnchor (top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
           if let top = top {
               self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = false
           }
           if let leading = leading {
               self.leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = false
           }
           if let trailing = trailing {
               self.trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = false
           }
           if let bottom = bottom {
               self.bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = false
           }
           if size.height != 0 {
               self.heightAnchor.constraint(equalToConstant: size.height).isActive = false
           }
           if size.width != 0 {
               self.widthAnchor.constraint(equalToConstant: size.width).isActive = false
           }
        
    }
    
}
