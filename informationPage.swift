//
//  informationPage.swift
//  HammockUP
//
//  Created by Anthony Guillard on 07/01/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit

class informationPage: UIViewController {
    
    // MARK: - Global variables
    
    //global variables
    lazy var closeButt: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cancel"), for: .normal)
        //button.setTitle("Close", for: .normal)
        //button.backgroundColor = UIColor(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)
        //button.layer.cornerRadius = 5.0
        //button.titleLabel!.font = UIFont(name: "Avenir", size: 18.0)
        button.addTarget(self, action: #selector(closeInfoPage), for: .touchUpInside)
        return button
    }()
    
    //note from developper
    lazy var noteFromDevelopper: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        label.text = "A note from the developper"
        label.font = UIFont(name: "Rockwell", size: 24.0)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    lazy var informationText: UITextView = {
        let textView = UITextView()
        textView.text = "First off, I'd like to thank you for using this app, whether you're a frequent or new user.\n\nMy goal when I started developping this app was to make people reconnect with nature through technology.\n\nI also want this app to belong to the community which is why everyone can add spots and remove them. I am not planning on limiting this option, so I ask everyone to be responsible and to not delete markers unless you need to. \n\nI am not planning on making any money from this app, which is why some features are not available. I am always down to exchange with you and get your feedback on how to improve the app. I will add numerous features as the community grows. \n\nFurthermore, anyone who knows me knows that I have an unconditional respect for nature and animals. If you'd like to support this global project, I encourage you to donate to the WWF (which is accessible here: https://support.worldwildlife.org/site/SPageServer?pagename=main_monthly&s_src=AWE2007OQ18299A01179RX&_ga=2.213728274.745515403.1587742390-646401887.1587742390)\n\nOnce again, thanks to each and every one of you. You can email me at pacha@tutanota.com for any information or feedback. Take care 😊"
        textView.font = UIFont(name: "Avenir", size: 18.0)
        textView.backgroundColor = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1)
        textView.textColor = .white
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(red: 11/255, green: 102/255, blue: 35/255, alpha: 1)]
        textView.layer.cornerRadius = 10.0
        return textView
    }()
    //outlets
    
     // MARK: - View did load
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor(red: 50/255, green: 64/255, blue: 56/255, alpha: 1)//UIColor(red: 143/255, green: 151/255, blue: 121/255, alpha: 1)
        view.addSubview(closeButt)
        view.addSubview(informationText)
        view.addSubview(noteFromDevelopper)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setConstraintInfoPage()
    }
    
    @objc func closeInfoPage() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Constraints
    func setConstraintInfoPage() {
        
        //noteFromDev
        noteFromDevelopper.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 30, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 30))
        
        //info text
        informationText.anchor(top: noteFromDevelopper.bottomAnchor, leading: view.leadingAnchor, bottom: closeButt.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 30, left: 20, bottom: 30, right: 20))
        
        //close button
        closeButt.anchor(top: nil, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.bottomAnchor, trailing: nil, padding: .init(top: 0, left: view.frame.width/2 - view.frame.height*0.0222, bottom: 30, right: 0), size: .init(width: view.frame.height * 0.0444, height: view.frame.height * 0.0444))
    }

}
