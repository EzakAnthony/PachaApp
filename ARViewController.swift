//
//  ARViewController.swift
//  HammockUP
//
//  Created by Anthony Guillard on 17/10/2020.
//  Copyright © 2020 Anthony Guillard. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController {

    private let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show statistics such as fps and timing information
        self.ARConnection.showsStatistics = true
        self.ARConnection.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        addBox()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var ARConnection: ARSCNView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.ARConnection.session.run(configuration)
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ARConnection.session.pause()
    }
    
    private var node: SCNNode!
     
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
            // 1
            let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
     
            // 2
            let colors = [UIColor.green, // front
                UIColor.red, // right
                UIColor.blue, // back
                UIColor.yellow, // left
                UIColor.purple, // top
                UIColor.gray] // bottom
            let sideMaterials = colors.map { color -> SCNMaterial in
                let material = SCNMaterial()
                material.diffuse.contents = color
                material.locksAmbientWithDiffuse = true
                return material
            }
            box.materials = sideMaterials
     
            // 3
            self.node = SCNNode()
            self.node.geometry = box
            self.node.position = SCNVector3(x, y, z)
     
            //4
            ARConnection.scene.rootNode.addChildNode(self.node)
        }
    
    private func addTapGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
            self.ARConnection.addGestureRecognizer(tapGesture)
        }
    
    @objc func didTap(_ gesture: UIPanGestureRecognizer) {
            // 1
            let tapLocation = gesture.location(in: self.ARConnection)
            let results = self.ARConnection.hitTest(tapLocation, types: .featurePoint)
     
            // 2
            guard let result = results.first else {
                return
            }
     
            // 3
            let translation = result.worldTransform.translation
     
            //4
            guard let node = self.node else {
                self.addBox(x: translation.x, y: translation.y, z: translation.z)
                return
            }
            node.position = SCNVector3Make(translation.x, translation.y, translation.z)
            self.ARConnection.scene.rootNode.addChildNode(self.node)
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
