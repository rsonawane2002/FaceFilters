//
//  FaceNode.swift
//  CameraFilter
//
//  Created by Rohit Sonawane on 7/2/22.
//

import Foundation
import ARKit

class FaceNode: SCNNode {
    var index = 0
    var names: [String]
    init(with names: [String], width: CGFloat = 0.08, height: CGFloat = 0.02){
        self.names = names
        
        super.init()
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = UIImage(named: names.first!)
        geometry = plane
    }
    
    required init?(coder decoder: NSCoder)
    {
        fatalError("Could not implement init function")
    }
    
    func update(for vectors: [vector_float3]){
        position = SCNVector3((vectors.reduce(vector_float3(), +) / Float(vectors.count)))
    }
    func next()
    {
        index = (index + 1) % names.count
        
        if let plane = geometry as? SCNPlane{
            plane.firstMaterial?.diffuse.contents = UIImage(named: names[index])
        }
    }
}
