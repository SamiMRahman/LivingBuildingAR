//
//  ViewController.swift
//  LivingBuildingAR
//
//  Created by Rahman, Sami M on 6/11/19.
//  Copyright © 2019 Rahman, Sami M. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Enable environment-based lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Object Detection
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "BuildingObjects", bundle: Bundle.main)!
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        //sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        /*
         Check To See Whether AN ARObject Anhcor Has Been Detected
         Get The The Associated ARReferenceObject
         Get The Name Of The ARReferenceObject
         */
        guard let objectAnchor = anchor as? ARObjectAnchor else { return }
        
        let detectedObject = objectAnchor.referenceObject
        guard let detectedObjectName = detectedObject.name else { return }
        
        //Get The Extent & Center Of The ARReferenceObject
        let detectedObjectExtent = detectedObject.extent
        let detectedObjecCenter = detectedObject.center
        
        //Log The Data
        print("""
            An ARReferenceObject Named \(detectedObjectName) Has Been Detected
            The Extent Of The Object Is \(detectedObjectExtent)
            The Center Of The Object Is \(detectedObjecCenter)
            """)
        
        //Create A Different Scene For Each Detected Object
        node.addChildNode(createSKSceneForReferenceObject(detectedObject: detectedObject))
        
        // Animate the WebView to the right
    }
    
    /// Creates A Unique SKScene Based On A Detected ARReferenceObject
    ///
    /// - Parameter detectedObject: ARReferenceObject
    /// - Returns: SCNNode
    func createSKSceneForReferenceObject(detectedObject: ARReferenceObject) -> SCNNode{
        
        let plane = SCNPlane(width: CGFloat(detectedObject.extent.x * 1.0),
                             height: CGFloat(detectedObject.extent.y * 0.7))
        
        plane.cornerRadius = plane.width / 8
        
        guard let validName = detectedObject.name else { return SCNNode() }
        
        let spriteKitScene = SKScene(fileNamed: validName)
        
        plane.firstMaterial?.diffuse.contents = spriteKitScene
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(detectedObject.center.x, detectedObject.center.y + 0.5, detectedObject.center.z)
        //HOW TO HAVE LABEL NODE CONNECTED TO A WEBSITE API
        //LIKE: "This water system (decreased/increased) water usage by (insert daily website data)!
        
        self.displayWebView(on: planeNode, xOffset: 7)
        
        return planeNode
    }
    
    func displayWebView(on rootNode: SCNNode, xOffset: CGFloat) {
        // Xcode yells at us about the deprecation of UIWebView in iOS 12.0, but there is currently
        // a bug that does now allow us to use a WKWebView as a texture for our webViewNode
        // Note that UIWebViews should only be instantiated on the main thread!
        DispatchQueue.main.async {
            let request = URLRequest(url: URL(string: "https://ce.gatech.edu/")!)
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672))
            webView.loadRequest(request)
            
            let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
            webViewPlane.cornerRadius = 0.25
            
            let webViewNode = SCNNode(geometry: webViewPlane)
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            webViewNode.position.z -= 0.5
            webViewNode.opacity = 0
            
            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1.5),
                .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
                ])
            )
        }
    }
    
    
    //    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    //
    //        let node = SCNNode()
    //
    //        if let objectAnchor = anchor as? ARObjectAnchor {
    //            let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 1.0), height: CGFloat(objectAnchor.referenceObject.extent.y * 0.7))
    //
    //            plane.cornerRadius = plane.width / 8
    //
    //            let spriteKitScene = SKScene(fileNamed: "ProductInfo")
    //
    //            plane.firstMaterial?.diffuse.contents = spriteKitScene
    //            plane.firstMaterial?.isDoubleSided = true
    //            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
    //
    //            let planeNode = SCNNode(geometry: plane)
    //            planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.5, objectAnchor.referenceObject.center.z) //y was 0.25
    //
    //            node.addChildNode(planeNode)
    //
    //        }
    //
    //        return node
    //    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
