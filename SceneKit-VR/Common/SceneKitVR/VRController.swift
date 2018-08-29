import Foundation
import SceneKit

extension SCNMaterial {
    convenience init(color: UIColor) {
        self.init()
        diffuse.contents = color
    }
}

extension SCNBox {
    convenience init(squaredSize size: CGFloat) {
        self.init(width: size, height: size, length: size, chamferRadius: 0)
    }
}

final class VRController: NSObject {
    let scene: SCNScene

    private let world: SCNNode
    private let cursor: SCNNode
    private var boxes: SCNNode
    private var focusedNode : SCNNode?

    private let greyMaterial = SCNMaterial(color: .gray)
    private let purpleMaterial = SCNMaterial(color: .purple)

    required override init() {
        scene = SCNScene()
        world = SCNNode()
        cursor = SCNNode()
        boxes = SCNNode()

        scene.background.contents = UIColor.lightGray
        
        for i in -3 ..< 13 {
            for j in 7 ..< 12 {
                let boxNode = SCNNode(geometry: SCNBox(squaredSize: 1))
                boxNode.geometry?.materials = [greyMaterial]
                boxNode.position = SCNVector3((Double(i) - 5.0) * 1.2, (Double(j) - 5.0) * 1.2, -10)
                boxNode.physicsBody = SCNPhysicsBody.static()
                boxes.addChildNode(boxNode)
            }
        }
        
        world.addChildNode(boxes)
        
        let floor = SCNFloor()
        floor.reflectivity = 0 // does not work in Cardboard SDK
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -20, 0)
        world.addChildNode(floorNode)
        
        let light = SCNLight()
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(2,2,2)
//        world.addChildNode(lightNode)

        cursor.geometry = SCNSphere(radius: 0.2)
//        cursor.physicsBody = nil

        scene.rootNode.addChildNode(cursor)
        scene.rootNode.addChildNode(world)
    }

    func prepareFrame(with headTransform: GVRHeadTransform) {
        cursor.position = headTransform.rotateVector(SCNVector3(0, -3, -9))
        // let's create long ray (100 meters) that goes the same way 
        // cursor.position is directed 
        
        let p2 =
            SCNVector3FromGLKVector3(
                GLKVector3MultiplyScalar(
                    GLKVector3Normalize(
                        SCNVector3ToGLKVector3(cursor.position)
                    ),
                    100
                )
            )
        
        let hits = boxes.hitTestWithSegment(from: SCNVector3Zero,
                                            to: p2,
                                            options: [SCNHitTestOption.firstFoundOnly.rawValue: true])
        
        if let hit = hits.first {
            focusedNode = hit.node
        } else {
            focusedNode = nil
        }
        
        boxes.enumerateChildNodes { (node, end) in
            node.geometry?.materials = [greyMaterial]
        }
        
        focusedNode?.geometry?.materials = [purpleMaterial]
    }

    func eventTriggered() {
        focusedNode?.removeFromParentNode()
    }
}
