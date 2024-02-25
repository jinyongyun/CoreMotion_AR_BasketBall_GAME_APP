# CoreMotion_AR_BasketBall_GAME_APP
🏀 CoreMotion을 활용한 AR 농구 게임 앱 만들기!
![RPReplay_Final1708846272](https://github.com/jinyongyun/CoreMotion_AR_BasketBall_GAME_APP/assets/102133961/dbc16bd8-35a1-45b1-90ae-2498b81c05fa)

오늘 만들어 볼 것은 AR을 이용한 게임이다!

그렇게 복잡한 게임은 아니고, 단지 허공에 농구 골대를 띄워 사용자의 모션에 따라 공을 넣을 수 있도록 하는

게임 앱을 만들어보려고 한다.

사용자의 동작을 인식하기 위해서는 CoreMotion이라는 라이브러리가 필요하다.

## Core Motion이란?

[Core Motion | Apple Developer Documentation](https://developer.apple.com/documentation/coremotion)

Core Motion은 iOS device의 하드웨어에서 가속도계, 자이로스코프, 보수계, 자력계, 기압계 등에서 동작 관련 데이터 및 이벤트를 추적하고 사용할 수 있도록 해주는 프레임워크이다.

예를 들어 우리가 이번에 하는 것처럼 게임 내에서 가속도계와 자이로스코프 입력을 사용하여 화면상의 게임 동작을 제어할 수도 있다.

이 프레임워크는 모션 데이터에 대한 access를 두 가지 경우로 나누어서 제공한다.

하나는 원시값

나머지는 처리된 값

원시값은 하드웨어에서 수정되지 않은 데이터를 반영하고

처리된 값은 데이터 사용에 부정적인 영향을 미칠 수 있는 편향 정보를 제거한다.(예를 들어 처리된 후의 가속도계 값은 중력에 의한 가속도는 제거하고, 사용자에 의한 가속도만 반영된다.)

Core Motion을 이루는 subject에는 다음이 있다.

`[class CMMotionManager](https://developer.apple.com/documentation/coremotion/cmmotionmanager)`  : 모션 서비스를 시작하고 관리하기 위한 객체

즉 기기의 센서에 의해 감지되는 정보를 활용하려면 CMMotionManager 클래스의 객체를 만들어줘야 한다.

이 CMMotionManager로 받을 수 있는 모션 데이터의 종류는 총 4가지가 있다.

- **Accelerometer(가속도계) 데이터** : 3차원 공간에서 기기의 순간 가속도를 나타내는 데이터
- **Gyroscope(자이로스코프) 데이터** : 기기의 3가지 주요 축 주변의 즉각적인 회전을 나타내는 데이터
- **Magnetometer(자력계) 데이터** : 지구의 자기장에 대한 기기의 방향을 나타내는 데이터
- **Device-motion 데이터** : 위의 데이터들에 대해 Core Motion의 센서 융합 알고리즘을 적용해서 가공된 채로 제공되는 데이터

중요한 점은 이 CMMotionManager 객체는 한 앱에 하나의 객체만 만들어야 한다는 점이다. 만약 여러 인스턴스를 만든다면 시스템이 가속도계 그리고 자이로스코프에서 데이터를 수신하는 속도에 영향을 미친다고 하니 꼭 주의하자!

CMMotionManager를 사용하면 개발자가 지정한 업데이트 간격으로 실시간 센서 데이터를 수집할 수도 있다.

그러려면 3가지 요소가 필요하다.

- 업데이트 간격을 지정하는데 필요한 interval 프로퍼티 값
- 업데이트 시작을 위한 start 메서드
- 업데이트 중지를 위한 stop 메서드

당연히 수집하는 데이터의 종류에 따라 다른 핸들러, 다른 메서드를 사용한다.

- **Accelerometer**
    - ***accelerometerUpdateInterval*** : 업데이트 간격을 지정
    - ***startAccelerometerUpdates(to:withHandler:)*** 메서드 :
        - 가속도계 데이터는 CMAccelerometerHandler 타입의 withHandler 블록 안에서 CMAccelerometerData 타입의 객체로 전달
    - ***stopAccelerometerUpdates()*** : 업데이트 중지
- **Gyroscope**
    - ***gyroUpdateInterval*** : 업데이트 간격을 지정
    - ***startGyroUpdates(to:withHandler:)*** 메서드 :
        - 회전 속도 데이터는 CMGyroHandler 타입의
            
            withHandler 블록 안에서 CMGyroData 타입의 객체로 전달
            
    - ***stopGyroUpdates()*** : 업데이트 중지
- **Magnetometer**
    - ***magnetometerUpdateInterval*** : 업데이트 간격을 지정
    - ***startMagnetometerUpdates(to:withHandler:)*** 메서드 :
        - 자기장 데이터는 CMMagnetometerHandler 타입의 withHandler 블록 안에서 CMMagnetometerData 타입의 객체로 전달
    - ***stopMagnetometerUpdates()*** : 업데이트 중지
- **Device motion**
    - ***deviceMotionUpdateInterval*** : 업데이트 간격을 지정
    - ***startDeviceMotionUpdates(using:)***  &&
    - ***startDeviceMotionUpdates(using:to:withHandler)*** &&
    - ***startDeviceMotionUpdates(to:withHandler:)*** 메서드 :
        - device motion 데이터는 CMDeviceMotionHandler 타입의 withHandler 블록 안에서 CMDevicecMotion 타입의 객체로 전달
    - ***stopDeviceMotionUpdates()*** : 업데이트 중지

### 간단한 적용 과정

CoreMotion 프레임워크를 사용해서 

지정한 interval에 맞게 ***device motion 데이터***를 추적하는 코드를 작성해보자!

- 먼저 CoreMotion 프레임워크를 import

```swift
import CoreMotion
```

- CMMotionManager() 인스턴스를 생성

```swift
let motionManager = CMMotionManager()
```

- device motion을 현재 기기에서 수집 가능한지 확인한다.

```swift
guard motionManager.isDeviceMotionAvailable else {
    print("Device motion data is not available")
    return
}
```

- 모션 갱신 주기를 설정해준다.
    - Interval 값은 1개의 데이터값이 수집되는데 걸리는 시간을 의미!
    - 0.1 (1/10) **⇒**  초당 10개의 데이터 수집을 의미한다. (10Hz)

```swift
motionManager.deviceMotionUpdateInterval = 0.1
```

- device motion 업데이트를 받기 시작한다!

```swift
motionManager.startDeviceMotionUpdates(to: .main) { (deviceMotion: CMDeviceMotion?, error: Error?) in
    guard let data = deviceMotion, error == nil else {
        print("Failed to get device motion data: \(error?.localizedDescription ?? "Unknown error")")
        return
    }
}
```

- device motion 업데이트를 중지

```swift
motionManager.stopDeviceMotionUpdates()
```

# ⛹🏻 AR 농구 게임 앱 제작 과정

필요한 준비물은 다음과 같다

우선 농구공 node에 diffuse해 줄 농구공 커버 이미지 하나

그리고 농구골대.scn 파일 하나
<img width="1146" alt="스크린샷 2024-02-25 오후 3 57 16" src="https://github.com/jinyongyun/CoreMotion_AR_BasketBall_GAME_APP/assets/102133961/b44b1460-8ab7-42e4-ace9-6079b3393469">
<img width="869" alt="스크린샷 2024-02-25 오후 3 57 32" src="https://github.com/jinyongyun/CoreMotion_AR_BasketBall_GAME_APP/assets/102133961/ccb518c5-dfdc-4495-9f2f-763e49d9cbde">



준비물이 전부 준비가 되었다면

viewController로 이동해서 이제 코드를 작성해보자.

준수한 **프로토콜**은 2가지

ARSCNViewDelegate, SCNPhysicsContactDelegate이다.

ARSCNViewDelegate는 뭐 AR앱이니까 일단 기본적으로 필요하고(앞에서도 계속 사용)

두 오브젝트의 충돌과 작용을 설정하기 위해 SCNPhysicsContactDelegate도 준수해야만 한다!

**프로퍼티**로는 위에서 설명했던 CMMotionManager 클래스 타입의 객체 하나

농구공 이름을 담을 배열 하나

충돌한 농구공과 해당 횟수를 설정한 딕셔너리 배열 하나

그리고 마지막 농구공이 생성된 시간을 저장하는 Date 객체 하나가 필요하다

```swift
 // CMMotionManager 인스턴스 생성 : 모션 정보를 얻기 위한 객체
    let motionManager: CMMotionManager = {
        let result = CMMotionManager()
        // 모션 갱신 주기 설정 - 30초당 1개의 데이터 수집
        result.accelerometerUpdateInterval = 1/30
        return result
    }()
    
    // 농구공 담을 배열 -> 농구공 이름은 UUID로 밑에서 생성 예정
    var balls = [String]()
    // 백보드와 충돌한 농구공의 이름과 그 횟수를 매칭하는 딕셔너리 배열 
    var contactedBalls = [String: Int]()

    // 마지막 농구공 생성된 시간
    var lastBall = Date()
```

각각의 쓰임은 아래에서 차차 함수를 작성해 나가면서 알아보자.

먼저 viewDidLoad()는 어떻게 구성했냐…

```swift
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
```

자 다음과 같이 구성해줬다.

일단 델리게이트는 2번째와 마지막에서 설정해줬고

```swift
 sceneView.showsStatistics = true
```

**`sceneView.showsStatistics`**는 ARSCNView의 프로퍼티 중 하나이다. 

이 프로퍼티는 SceneKit이 렌더링 및 프레임 속도와 같은 통계 정보를 표시할지 여부를 나타낸다.

일반적으로 개발 및 디버깅 목적으로 사용되며, 앱의 성능을 모니터링하고 최적화할 때 유용하다. 

이번에는 여러 액션이나 모션이 많아서 얼마나 성능이 나오는지 확인하기 위해서 설정했다.

이녀석을 true로 하면 ARSCNView는 디바이스 화면의 한 쪽에 추가 정보를 표시하여 프레임 속도, 렌더링 시간 등과 같은 성능 관련 정보를 실시간으로 표시한다.

SCNPhysicsContactDelegate를 설정해준 이유가 

바로 다음의 physicsWorld 메서드를 이용하기 위해서이다.

이 physicsWorld 메서드는 SceneKit의 물리 세계에서 두 물체가 충돌했을 때 호출된다.

상세 내용은 아래 주석에 굉장히 상세히 적어놓았으나

간략하게 말하자면

백보드와 공, 이 두 물체가 충돌했을 때

충돌한 그 볼의 충돌 횟수를 늘려주는 메서드이다.

```swift
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
            }
        }
    }
```

두 번째로 viewDidLoad에서 보았던 addBackboard()를 작성해보자.

이녀석은 쉽게 말해서 scn 파일에 속한 3가지 노드 backboard, net, score 를 구현하고 

오브젝트끼리의 물리적 충돌을 위해 실제 물리적 형상을 갖추도록 설정하는 부분이다. 

상세한 설명은 주석으로 자세히 작성해놓았다.

천천히 읽어나가면 이해할 수 있을 것이다.

```swift
 // 백보드를 추가하는 메서드
    func addBackboard() {
        
        // art.scnassets에 저장해둔 백보드 scn 파일을 인스턴스화
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else { return }
        
        // 백보드 scn 파일은 총 세 개의 노드로 이루어져 있다 [백보드, 네트, 공이 들어간 걸 인식하는 센서]
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false), 
        let netNode = backboardScene.rootNode.childNode(withName: "net", recursively: false), 
        let sensorNode = backboardScene.rootNode.childNode(withName: "score", recursively: false) else { return }
        
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
        
        // 골대가 좌우로 움직이도록 하는 함수, 각 노드에 전부 설정 (밑에서 정의) 
        horizontalAction(node: backboardNode)
        horizontalAction(node: sensorNode)
        horizontalAction(node: netNode)
        
        // 노션의 적용 과정에서 보았던 (그쪽은 startDeviceMotionUpdates) 디바이스 가속계 업데이트 하는 부분
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            self.handleShake(data, error)
        }
    }
    
```

addBackboard함수에는 horizontalAction과 handleShake 함수가 사용되었는데

차례대로 알아보자.

먼저 horizontalAction 함수는 골대가 좌우로 움직이는 액션을 만들기 위한 함수이다.

SCNAction을 통해 좌우로 움직일 수 있도록 했고

해당 SCNAction을 사용한 좌, 우 움직임을 sequence로 묶어

계속해서 이 액션을 반복하여 수행할 수 있도록 했다.

```swift
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
```

handleShake는 

```swift
 // 노션의 적용 과정에서 보았던 (그쪽은 startDeviceMotionUpdates) 디바이스 가속계 업데이트 하는 부분
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            self.handleShake(data, error)
        }
```

해당 부분에서 사용됐는데, 디바이스의 가속계가 업데이트 될 때마다

즉 흔들릴때마다 호출되도록 addBackboard의 마지막에서 설정했다.

이 함수에 대해 간략히 설명하자면

디바이스 즉 우리가 바라보는 카메라 방향에 농구공 오브젝트를 생성한 다음

디바이스의 가속계 정보에 따라 농구공 오브젝트에 가해지는 힘을 설정해 

백보드에 충돌할 수 있도록 설정했다.

```swift
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
```

## 실제 구동 화면


https://github.com/jinyongyun/CoreMotion_AR_BasketBall_GAME_APP/assets/102133961/e28f785b-779d-46e5-8010-4823e0aaaf00

