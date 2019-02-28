//
//  GameController.swift
//  Tetra Shared
//
//  Created by Joss Manger on 2/28/19.
//  Copyright © 2019 Joss Manger. All rights reserved.
//

import SceneKit
import ModelIO

func degToRad(degrees:Float)->CGFloat{
    return CGFloat(degrees * (.pi / 180))
}

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    typealias SCNColor = NSColor
    typealias Image = NSImage
#else
    typealias SCNColor = UIColor
    typealias Image = UIImage
#endif

class GameController: NSObject, SCNSceneRendererDelegate {

    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    var pod:SCNNode!
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        scene = SCNScene(named: "Art.scnassets/tetrapod.scn")!
        
        super.init()
        
        sceneRenderer.delegate = self
        
        let plane = SCNPlane(width: 10, height: 10)
        let planenode = SCNNode(geometry: plane)
        planenode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: plane, options: nil))
        
        planenode.rotation = SCNVector4.init(1, 0, 0, degToRad(degrees: -90))
        planenode.geometry!.firstMaterial!.isDoubleSided = true
        planenode.position = SCNVector3(x: 0, y: -3, z: 0)
        let material = SCNMaterial()
        let path = Bundle.main.path(forResource: "concrete", ofType: "jpg", inDirectory: "Art.scnassets")!
        print(path)
        let img = Image(contentsOfFile: path)
        print(img)
        material.diffuse.contents = img
        
        plane.materials = [material]
        scene.rootNode.addChildNode(planenode)
        
        //scene.background.contents = MDLSkyCubeTexture(name: nil,
//                                                      channelEncoding: .uInt8,
//                                                      textureDimensions: [Int32(160), Int32(160)],
//                                                      turbidity: 0,
//                                                      sunElevation: 10,
//                                                      upperAtmosphereScattering: 10,
//
//                                                      groundAlbedo: 2)
        
        if let pod = scene.rootNode.childNode(withName: "tetrapod", recursively: true) {
            //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
            self.pod = pod
            pod.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: pod.geometry!, options: nil))
            pod.position = .init()
        }
        
        sceneRenderer.scene = scene
    }
    
    func addPod(){
        let pod = self.pod.clone()
        pod.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: pod.geometry!, options: nil))
        pod.position = .init()
        scene.rootNode.addChildNode(pod)
    }
    
    func highlightNodes(atPoint point: CGPoint) {
        let hitResults = self.sceneRenderer.hitTest(point, options: [:])
        for result in hitResults {
            // get its material
            guard let material = result.node.geometry?.firstMaterial else {
                return
            }
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = SCNColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = SCNColor.red
            
            SCNTransaction.commit()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
    }

}
