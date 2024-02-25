//
//  ViewController.swift
//  BasketBallGame_AR
//
//  Created by jinyong yun on 2/24/24.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion


// SCNPhysicsContactDelegate는 두 객체 사이 상호작용 모션 받는 delegate 즉 백보드와 농구공 사이의 상호작용 담당
class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    // CMMotionManager 인스턴스 생성 : 모션 정보를 얻기 위한 객체
    let motionManager: CMMotionManager = {
        let result = CMMotionManager()
        // 모션 갱신 주기 설정 - 30초당 1개의 데이터 수집
        result.accelerometerUpdateInterval = 1/30
        return result
    }()
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARSCNViewDelegate 설정
        sceneView.delegate = self
        
        // fps 또는 timing information 같은 statistics를 보여준다
        sceneView.showsStatistics = true
        
        // 새로운 scene 객체
        let scene = SCNScene()
        
        // 뷰의 scene에 위에서 생성한 빈 scene 설정
        sceneView.scene = scene
        
        // 백보드 추가하는 메서드
        addBackboard()
        
        // SCNPhysicsContactDelegate 설정
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    // 농구공 담을 배열
    var balls = [String]()
    // 들어간 볼 담을 딕셔너리 배열
    var contactedBalls = [String: Int]()
    
    
    // SCNPhysicsWorldDelegate 프로토콜을 준수하며, SceneKit의 물리 세계에서 두 물체가 충돌했을 때 호출
    // world는 해당 물리 세계를 나타내는 SCNPhysicsWorld 인스턴스이며,
    // contact는 충돌에 대한 정보를 포함하는 SCNPhysicsContact 인스턴스
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
        
        // 충돌한 두 물체 중 노드 B의 이름을 가져온다.
        // 여기서는 노드 B가 농구공이라고 가정한다.
        // 만약 노드 B의 이름이 존재하지 않는다면, 충돌한 물체 중 농구공이 아니라고 판단하고 처리를 종료시킨다.
        if let name = contact.nodeB.name {
            // 농구공의 이름을 키로 사용하여 contactedBalls 딕셔너리에 접근한다.
            // 만약 해당 농구공이 딕셔너리에 존재한다면, 기존 값에 1을 더하여 업데이트한다.
            // 만약 딕셔너리에 해당 이름의 키가 존재하지 않는다면, 0에 1을 더한 값을 대입하여 새로운 키-값 쌍을 추가한다.
            contactedBalls[name] = (contactedBalls[name] ?? 0) + 1
            
            // 농구공이 8번 접촉했는지 확인한다. contactedBalls 딕셔너리에서 해당 농구공의 접촉 횟수를 가져와서, 8번과 비교.
            // 만약 접촉 횟수가 8번이라면, "Score 8 Completed!"를 출력한다.
            if ((contactedBalls[name] ?? 0) == 8) {
                print("Score 8 Completed!")
                //화면상에서 텍스트 노드 띄우기 (cm 사용자에게 알려주기, 위치 기준은 엔드포인트)
            }
        }
    }
    
    // 백보드를 추가하는 메서드
    func addBackboard() {
        
        // art.scnassets에 저장해둔 백보드 scn 파일을 인스턴스화
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else { return }
        
        // 백보드 scn 파일은 총 세 개의 노드로 이루어져 있다 [백보드, 네트, 공이 들어간 걸 인식하는 센서]
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false), let netNode = backboardScene.rootNode.childNode(withName: "net", recursively: false), let sensorNode = backboardScene.rootNode.childNode(withName: "score", recursively: false) else { return }
        
        // 각 노드의 위치 설정
        backboardNode.position = SCNVector3(x: 0, y: 0.75, z: -5)
        sensorNode.position = SCNVector3(x: 0.042, y: 0.945, z: -4.385)
        netNode.position = SCNVector3(x: -0.022, y: 0.75, z: -5.02)
        
        // collision detection을 위한 백보드 노드의 실제 물리 형상 - 모양은 concavePolyhedron (오목한 다면체)
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        
        /*
         공식문서 SCNPhysicsBody
         ===========================================================
         To add physics to a node,
         create and configure an SCNPhysicsBody object and then
         assign it to the physicsBody property of the SCNNode object.
         ===========================================================
         */
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        // SCNPhysicsBody를 만들어야 노드의 physicsBody 속성에 할당 가능!
        backboardNode.physicsBody = physicsBody
        
        // 루트 노드 밑에 백보드 노드 추가
        sceneView.scene.rootNode.addChildNode(backboardNode)
        
        
        // 이번에는 센서 노드 만들기 - 위와 마찬가지로 SCNPhysicsShape와 SCNPhysicsBody를 만든다.
        sensorNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: sensorNode))
        
        // 노드의 physicsBody 는 다음과 같은 프로퍼티를 가지고 있음
        // categoryBitMask — 오브젝트의 타입을 정의하는 숫자. 이는 다른 물체와의 충돌을 고려해 지정된 것으로 32가지의 다른 값을 가질 수 있고 default value는 0xFFFFFFFF
        // collisionBitMask — 해당 노드가 어떤 categoryBitMask를 가진 오브젝트와 충돌할지 정의하는 숫자. default value는 “모든 것”을 의미하는 0xFFFFFFFF로 모든것에 대해 반응 가능.
        sensorNode.physicsBody?.categoryBitMask = 8
        sensorNode.physicsBody?.collisionBitMask = 0
        
        
        
        // 센서 노드와 네트 노드도 루트 노드 밑에 추가
        sceneView.scene.rootNode.addChildNode(sensorNode)
        sceneView.scene.rootNode.addChildNode(netNode)
        
        horizontalAction(node: backboardNode)
        horizontalAction(node: sensorNode)
        horizontalAction(node: netNode)
        
        // 노션의 적용 과정에서 보았던 (그쪽은 startDeviceMotionUpdates) 디바이스 가속계 업데이트 하는 부분
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            self.handleShake(data, error)
        }
    }
    
    // 마지막 농구공 생성된 시간
    var lastBall = Date()
    
    // 디바이스를 흔들면 농구공을 생성하고 해당 방향으로 움직이게 하는 함수
    func handleShake(_ data: CMAccelerometerData?, _ error: Error?) {
        
        //error가 없고, 가속계에서 업데이트 된 데이터의 acceleration z값이 무사히 추출되면 통과
        // acceleration의 z 값은 z축에 작용하는 중력 가속도
        guard error == nil, let a = data?.acceleration.z else { return }
        
        // acceleration.z 값에 절댓값 씌우기
        let acc = abs(a)
        
        // z축 가속의 절댓값이 2 이상이고, lastBall이 생성된지 0.2초 이상 지났는지 확인
        if acc >= 2 && lastBall.advanced(by: 0.2).compare(Date()) == .orderedAscending {
            
            // 마지막 농구공 생성된 시간 업데이트
            lastBall = Date()
            
    
            // SceneKit 뷰의 pointOfView를 사용하여 카메라의 위치와 방향을 계산하는 부분
            //  이를 통해 AR 환경에서 카메라의 위치와 방향을 고려하여 오브젝트를 배치할 수도 있다
            // ARSCNView의 pointOfView 속성에서 카메라의 위치와 방향을 추출하기 위해 sceneView의 pointOfView를 가져옵니다. 만약 pointOfView가 nil이면 함수 실행을 중단하고 반환
            guard let centerPoint = sceneView.pointOfView else { return }
            
            /*
             centerPoint의 transform 속성을 사용하여 카메라의 변환 행렬을 cameraTransform에 할당한다.
             이 행렬은 카메라의 위치와 방향을 나타낸다.
             ┌                      ┐
             |  m11  m21  m31  m41  |
             |  m12  m22  m32  m42  |
             |  m13  m23  m33  m43  |
             |  m14  m24  m34  m44  |
             └                      ┘
             */
            
            let cameraTransform = centerPoint.transform
            
            // 변환 행렬에서 카메라의 위치를 추출하여 SCNVector3 형태로 cameraLocation에 저장한다.
            // m41, m42, m43은 각각 변환 행렬의 네 번째 열에서 x, y, z 위치를 나타낸다.
            let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
            
            // 변환 행렬에서 카메라의 방향을 추출하여 SCNVector3 형태로 cameraOrientation에 저장한다.
            // 여기서는 카메라의 방향을 나타내는 행렬의 세 번째 열에서 x, y, z 방향을 가져온다.
            // 이 값들은 카메라의 방향을 나타내는 벡터이며, -를 붙여주어야 한다.
            // 이는 SceneKit에서의 좌표계와 일치시키기 위함이다.
            let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
            
            // cameraLocation과 cameraOrientation을 더하여 카메라의 위치를 나타내는 SCNVector3를 생성한다.
            // 이렇게 함으로써 카메라의 위치와 방향을 고려한 실제 3D 공간상의 위치를 얻을 수 있다!
            let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
            
            
            // 반지름이 0.2인 농구공 노드 만들기
            let ball = SCNSphere(radius: 0.2)
            
            // 농구공 재질 설정을 위한 SCNMaterial 객체
            let ballMaterial = SCNMaterial()
            
            // 농구공 재질 설정
            ballMaterial.diffuse.contents = UIImage(named: "basketballSkin.png")
            ball.materials = [ballMaterial]
            
            // 빈 노드 생성
            let ballNode = SCNNode(geometry: ball)
            
            // 농구공의 위치를 카메라의 위치로 설정, 즉 사용자가 골대를 바라보고 있을테니 마치 공을 들고 있는 것처럼
            ballNode.position = cameraPosition
            // 볼 이름은 UUID값 사용
            ballNode.name = UUID().uuidString
            
            // 농구공 이름 배열에 추가
            balls.append(ballNode.name!)
            
            // 노드 모양대로 physicsShape 설정, 즉 노드 모양인 Sphere 구 모양
            let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
            // 농구공 노드에 물리 특성 부여
            let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
            
            // 충돌 감지를 위해 물리 바디의 contactTestBitMask를 설정
            physicsBody.contactTestBitMask = 8
            ballNode.physicsBody = physicsBody
            
            // 농구공에 가해지는 힘 설정
            // forceVector는 힘의 크기를 결정하는 변수, 이 값이 클수록 농구공에 가해지는 힘도 강해진다!
            let forceVector: Float = 3
            // SCNVector3를 사용하여 농구공에 가해지는 힘의 방향과 크기를 설정
            // x 축의 힘은 카메라의 x 방향인 cameraOrientation.x에 forceVector를 곱하여 결정
            // y 축의 힘은 카메라의 y 방향인 cameraOrientation.y에 절대값을 취한 가속도 값 Float(abs(acc))과 forceVector를 곱하여 결정
            // 가속도 값의 절대값을 사용하는 이유는 흔들림의 방향에 관계없이 항상 양수의 힘을 가하도록 하기 위함
            // z축도 y축과 동일
            ballNode.physicsBody?.applyForce(
                SCNVector3(
                    x: cameraOrientation.x * forceVector,
                    y: cameraOrientation.y * Float(abs(acc)) * forceVector,
                    z: cameraOrientation.z * Float(abs(acc)) * forceVector
                ),
                asImpulse: true // 힘을 순간적인 충격으로 적용할지 여부
            )
            
            sceneView.scene.rootNode.addChildNode(ballNode)
        }
        
    }
    
    // SceneKit에서 사용되는 SCNNode의 가로 이동 애니메이션을 설정
    func horizontalAction(node: SCNNode) {
        
        // leftAction은 노드를 x축의 음의 방향으로 1만큼 이동시키는 SCNAction이다.. 이동에는 2초가 걸린다.
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 2)
        // rightAction은 노드를 x축의 양의 방향으로 1만큼 이동시키는 SCNAction이다. 이동에는 역시 2초가 걸린다.
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 2)
        
        // actionSequence는 leftAction을 먼저 실행하고, 그 다음에 rightAction을 실행하는 연속된 액션 시퀀스를 나타낸다.
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        // 노드에 앞에서 생성한 액션 시퀀스를 반복적으로 실행하도록 지시한다.
        // 따라서 노드는 좌우로 번갈아가며 이동하는 애니메이션을 계속 반복하게 된다.
        node.runAction(SCNAction.repeatForever(actionSequence))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
