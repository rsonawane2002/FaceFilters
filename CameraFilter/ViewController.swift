//
//  ViewController.swift
//  CameraFilter
//
//  Created by Rohit Sonawane on 7/2/22.
//

import UIKit
import RealityKit
import ARKit
import ReplayKit


class ViewController: UIViewController, ARSCNViewDelegate, RPPreviewViewControllerDelegate{
    
    @IBOutlet var arView: ARSCNView!
    
    weak var viewController: UIViewController!
    
    
    let moustacheOptions = ["moustache01", "moustache02", "moustache03"]
    let features = ["mouth"]
    @IBOutlet var recordButton: UIButton!
    var featureIndices = [[24]]
    var index = 0
    
    private let planeWidth: CGFloat = 0.08
    private let planeHeight: CGFloat = 0.02
    private let nodeYPosition: Float = -0.0215
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
            previewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        record(sender)
    }
    
    @IBAction func record(_ sender : Any)
    {
        let image1 = UIImage(named: "start") as UIImage?
        let image2 = UIImage(named: "stop") as UIImage?
        
       let recorder =  RPScreenRecorder.shared()
        if !recorder.isRecording {
            recordButton.setImage(image2, for: .normal)
            recorder.startRecording { error in
                guard error == nil else {
                    print("Failed to record")
                    return
                }
            }
        }
        else{
            recordButton.setImage(image1, for: .normal)
            RPScreenRecorder.shared().stopRecording { (previewController: RPPreviewViewController?, error: Error?) in
                if previewController != nil {
                    let alertController = UIAlertController(title: "Recoring", message: "Do you want to discard or view your recording?", preferredStyle: .alert)
                    let discardAction = UIAlertAction(title: "Discard", style: .destructive, handler: nil)

                    let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action: UIAlertAction) in

                        // set delegate here
                        previewController?.previewControllerDelegate = self

                        self.present(previewController!, animated: true, completion: nil)
                    })

                    alertController.addAction(discardAction)
                    alertController.addAction(viewAction)
                    self.present(alertController, animated: true, completion: nil)
                }
        }
    }
    }
                            
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        guard ARFaceTrackingConfiguration.isSupported else {
                    fatalError("Face tracking is not supported on this device")
        }
        
        let image = UIImage(named: "start") as UIImage?
        recordButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 35,
                                              y: UIScreen.main.bounds.size.height-100,
                                              width: 70,
                                            height: 70))
        
        let bottomHalfRectangle = CAShapeLayer()
        bottomHalfRectangle.path = UIBezierPath(rect: CGRect(x: 0.0, y: view.frame.size.height-view.frame.midY/4, width: view.frame.size.width, height: view.frame.midY/4)).cgPath
        //bottomHalfRectangle.fillColor = uiColorFromHex(
        recordButton.setImage(image, for: .normal)
        
        recordButton.addTarget(self,
                         action: #selector(buttonAction),
                         for: .touchUpInside)
        
        self.view.layer.addSublayer(bottomHalfRectangle)
        self.view.addSubview(recordButton)
        
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        arView.isUserInteractionEnabled = true
        
        arView.delegate = self
        
        // Add the box anchor to the scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARFaceTrackingConfiguration()
        arView.session.run(config)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        let loc = sender.location(in: arView)
        let outputs = arView.hitTest(loc)
        if let output = outputs.first,
           let node = output.node as? SCNNode {
            index = (index + 1) % moustacheOptions.count
            
            if let plane = node.geometry as? SCNPlane{
                if(moustacheOptions[index] == "moustache02" || moustacheOptions[index] == "moustache03" )
                {
                    plane.height = planeHeight + 0.03
                }
                else{
                    plane.height = planeHeight
                }
                plane.firstMaterial?.diffuse.contents = UIImage(named: moustacheOptions[index])
            }
        }
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor)
    {
        for (feature, indices) in zip(features, featureIndices){
            let child = node.childNode(withName: feature, recursively: false) as? SCNNode
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            
            child?.position = SCNVector3((vertices.reduce(vector_float3(), +) / Float(vertices.count)))
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?
    {
            
            var device: MTLDevice!
            device = MTLCreateSystemDefaultDevice()
            let faceGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.transparency = 0.0
        
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        
        let moustachePlane = SCNPlane(width: planeWidth, height: planeHeight)
        
        moustachePlane.firstMaterial?.diffuse.contents = UIImage(named: "moustache01")


        let moustacheNode = SCNNode()
        moustacheNode.geometry = moustachePlane
        moustacheNode.position.z = node.boundingBox.max.z * 3 / 4
        moustacheNode.position.y = nodeYPosition
    
        
        node.addChildNode(moustacheNode)
        
        /*
        let occlusionNode = FaceNode(with: moustacheOptions)
        occlusionNode.name = "mouth"
        node.addChildNode(occlusionNode)
         */
        
        updateFeatures(for: node, using: faceAnchor)
            return node
        }
        
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
            
            guard let faceAnchor = anchor as? ARFaceAnchor,
                let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                    return
            }
            faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
}

