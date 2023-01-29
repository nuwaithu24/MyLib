//
//  Logger.swift
//  MyLib
//
//  Created by Nu Wai Thu on 2023/01/26.
//

import Foundation
import SkyWay
import AVFoundation
import AudioToolbox
import FirebaseCore
import FirebaseFirestore
import CallKit



public class TestViewController:UIViewController {
    
    public static let sharedInstance = TestViewController()
    fileprivate var peer: SKWPeer?
    fileprivate var dataConnection: SKWDataConnection?
    fileprivate var mediaConnection: SKWMediaConnection?
    fileprivate var localStream: SKWMediaStream?
    fileprivate var remoteStream: SKWMediaStream?

    @IBOutlet weak var myPeerIdLabel: UILabel!
   // @IBOutlet weak var localStreamView: SKWVideo!
   // @IBOutlet weak var remoteStreamView: SKWVideo!
    //@IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    
   // @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var testVIew: UIView!
    
    @IBOutlet weak var durationTimeLB: UILabel!
    
    @IBOutlet weak var answerView: UIView!
    
    
    var callCenter = CallCenter(supportsVideo: true)
    
    var paramString = [String:String]()
    
    
   // var emailLists = [String]()
   // var deviceTokens = [String]()
    var currentUserEmail = String()
    var currentPeerID = String()
    var receiverDeviceToken = String()
    var receiverFCMToken = String()
    var receiverEmail = String()
    var isFromEmailListVC = false
    public var isFromNoti = false
    var isFromIncomingCallNoti = false
    
    var window: UIWindow?
    
    var timer = Timer()
    var vibrateTimer = Timer()
    
    var countTimeNumber = 0
    
    var isShowAnswerBtn = false
    
    var deviceTokenbyself = ""
    
    
    var currentFcmToken = String()
    
    var skywayAPIKey = "fffdcd3e-0c79-4d9c-93f0-4316d46a76cd"
    var skywayDomain = "localhost"
    
    private let stackView: UIStackView = {
           $0.distribution = .fill
           $0.axis = .horizontal
           $0.alignment = .center
           $0.spacing = 10
           return $0
       }(UIStackView())

       private let circleA = UIView()
       private let circleB = UIView()
       private let circleC = UIView()
       private let circleD = UIView()
       private let circleE = UIView()
       private let circleF = UIView()
    
       private lazy var circles = [circleA, circleB, circleC,circleD, circleE, circleF]

       func animate() {
           let jumpDuration: Double = 0.30
           let delayDuration: Double = 1.25
           let totalDuration: Double = delayDuration + jumpDuration*2

           let jumpRelativeDuration: Double = jumpDuration / totalDuration
           let jumpRelativeTime: Double = delayDuration / totalDuration
           let fallRelativeTime: Double = (delayDuration + jumpDuration) / totalDuration

           for (index, circle) in circles.enumerated() {
               let delay = jumpDuration*2 * TimeInterval(index) / TimeInterval(circles.count)
               UIView.animateKeyframes(withDuration: totalDuration, delay: delay, options: [.repeat], animations: {
                   UIView.addKeyframe(withRelativeStartTime: jumpRelativeTime, relativeDuration: jumpRelativeDuration) {
                       circle.frame.origin.y -= 60
                   }
                   UIView.addKeyframe(withRelativeStartTime: fallRelativeTime, relativeDuration: jumpRelativeDuration) {
                       circle.frame.origin.y += 60
                   }
               })
           }
       }
    
   @objc func showDurationTime(_ timer: Timer)
    {
     // print("Hello")
        countTimeNumber = countTimeNumber + 1
        let durationTime = timeString(time: TimeInterval(countTimeNumber))
        self.durationTimeLB.text = durationTime
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let callerDeviceToken = UserDefaults.standard.object(forKey: "DeviceToken") as? String {
            self.deviceTokenbyself = callerDeviceToken
        }
        
        if let currentFcmToken = UserDefaults.standard.object(forKey: "FCMTOKEN") as? String {
            self.currentFcmToken = currentFcmToken
        }

        // Do any additional setup after loading the view.
        self.answerView.isHidden = true
        if isFromNoti {
            self.answerView.isHidden = false
        }
        
        self.durationTimeLB.isHidden = true
        self.endCallButton.isEnabled = true
        
        self.addBGImageBlurEffect()
       
        if let userEmail = UserDefaults.standard.object(forKey: "CurrentUserEmail") as? String {
            self.currentUserEmail = userEmail
        }
        
        if self.skywayAPIKey == nil || self.skywayDomain == nil {
            let alert = UIAlertController(title: "エラー", message: "APIKEYとDOMAINがAppDelegateに設定されていません", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            return
        }

        checkPermissionAudio()
        callCenter.setup(self)
        setup()
        addAnnimation()
        
       // NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("SendNoti"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.backUserEmailVC(notification:)), name: Notification.Name("EndCall"), object: nil)
        
       // NotificationCenter.default.addObserver(self, selector: #selector(self.notiFromEndCall(notification:)), name: Notification.Name("CallerEndCall"), object: nil)
        
    }
    
    
    deinit {
         print("Remove NotificationCenter Deinit")
         NotificationCenter.default.removeObserver(self)
     }
    
    public override func viewDidDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self)
     }
    
    public override func viewWillDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self)
        self.timer.invalidate()
        self.vibrateTimer.invalidate()
        
     }
    
    func addBGImageBlurEffect(){
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        //blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgImageView.addSubview(blurEffectView)
        
    }
    
    
    
    func addAnnimation(){
        
               testVIew.isHidden = false
               testVIew.backgroundColor = .clear
               testVIew.addSubview(stackView)
               stackView.translatesAutoresizingMaskIntoConstraints = false
               stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
               stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
               circles.forEach {
                   $0.layer.cornerRadius = 10/2
                   $0.layer.masksToBounds = true
                   $0.backgroundColor = .systemGreen
                   stackView.addArrangedSubview($0)
                   $0.widthAnchor.constraint(equalToConstant: 10).isActive = true
                   $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
               }
    }
    
    func removeAnnimation(){
        testVIew.isHidden = true
        isStartCalled = false
        
    }
    
   
    
    /*func fetchEmailLists(){
        
        Api.share.getEmailLists() { (results, error, code) in
            
            if let responseDatas = results {
                for res in responseDatas {
                    if let email = res.email {
                        print(email)
                        self.emailLists.append(email)
                    }
                    if let deviceToken = res.deviceToken {
                        self.deviceTokens.append(deviceToken)
                    }
                }
                
            }
        }
        
        
    }*/
    
    
   
    @objc func methodOfReceivedNotification(notification: Notification) {
        
       // self.showAlert(message: "GETNOTI")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            //self.showAlert(message: "GETNOTI")
            if let id = UserDefaults.standard.object(forKey: "targetID") as? String{
                
                self.call(targetPeerId: id)
            }
        }
            
    }
    
    @objc func backUserEmailVC(notification: Notification) {
        print("ENDNOTI")
        isStartCalled = false
        
        if isFromEmailListVC {
           
                self.dismiss(animated: true)
           
            
            
        } else {
            
            self.dataConnection?.close()
            self.mediaConnection?.close()
            self.changeConnectionStatusUI(connected: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
               /* let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "userListNav")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)*/
            }
            
           
            
        }
        
        
    }
    
    @objc func notiFromEndCall(notification: Notification) {
        
        
        
        print("notiFormEndCall")
        self.callCenter.EndCall()
        self.dataConnection?.close()
        self.mediaConnection?.close()
        DispatchQueue.main.async {
            
            if let email = UserDefaults.standard.object(forKey: "callerEmail") as? String {
                
                if email == self.currentUserEmail {
                    self.dismiss(animated: true)
                    self.changeConnectionStatusUI(connected: false)
                } else {
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "userListNav")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
            
          
            
        }
        
    }
    

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFromEmailListVC {
            self.call()
            self.userName.text = self.receiverEmail
            UserDefaults.standard.set(self.receiverEmail, forKey: currentConnectedEmail)
            
        } else {
            removeAnnimation()
            if let callerEmail = UserDefaults.standard.object(forKey: "notiCallerEmail") as? String {
                self.userName.text = callerEmail
                UserDefaults.standard.set(callerEmail, forKey: currentConnectedEmail)
            }
        }
        
        if isFromNoti {
            
            timer.invalidate()
            self.durationTimeLB.isHidden = true
            addAnnimation()
            animate()
            vibrateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                target: self,
                                                selector: #selector(vibrate(_:)),
                                                userInfo: nil,
                                                repeats: true)
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                //self.showAlert(message: "GETNOTI")
                if let id = UserDefaults.standard.object(forKey: "targetID") as? String{
                    //self.vibrateTimer.invalidate()
                    //self.call(targetPeerId: id)
                }
            }
        }
    }
    
    @objc func vibrate(_ timer: Timer)
     {
         UIDevice.vibrate()
     }
    
    

    
    func call (){
        
        
        
        guard let peer = self.peer else {
            return
        }
        
        

        showPeersDialog(peer) { peerId in
            print(peerId)
            
            self.callCenter.StartCall(false)
            self.connect(targetPeerId: peerId)
        }
    }
    
    @IBAction func tapAnswerCallAction(){
        self.answerView.isHidden = true
        if let id = UserDefaults.standard.object(forKey: "targetID") as? String{
            
            self.vibrateTimer.invalidate()
            self.removeAnnimation()
            self.durationTimeLB.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(showDurationTime(_:)),
                                         userInfo: nil,
                                         repeats: true)
            self.call(targetPeerId: id)
        }
       
        
        
    }

    @IBAction func tapEndCallAction(){
        print("ENDCALLBTN")
       
        self.saveHistoryEndCall()
        self.tapEndCall()
        self.sendEndCallNotification()
        
        
    }
    
    func saveHistoryEndCall(){
        if self.isFromEmailListVC {
            self.addHistory(titleNameEmail: self.currentUserEmail, email: self.receiverEmail, deviceToken: self.receiverDeviceToken, fcmToken: self.receiverFCMToken)
            self.addHistory(titleNameEmail: self.receiverEmail, email: self.currentUserEmail, deviceToken: self.deviceTokenbyself,fcmToken: self.currentFcmToken)
        } else {
            
            if let callerDeviceToken = UserDefaults.standard.object(forKey: "DeviceToken") as? String {
                self.deviceTokenbyself = callerDeviceToken
                if let currentFcmToken = UserDefaults.standard.object(forKey: "FCMTOKEN") as? String {
                    self.currentFcmToken = currentFcmToken
                    if let userEmail = UserDefaults.standard.object(forKey: "CurrentUserEmail") as? String {
                        self.currentUserEmail = userEmail
                        if let callerDeviceToken = UserDefaults.standard.object(forKey: "callerDeviceToken") as? String {
                            if let callerEmail = UserDefaults.standard.object(forKey: "notiCallerEmail") as? String {
                                if let callerFCMToken = UserDefaults.standard.object(forKey: "callerFCMToken") as? String {
                                    print(callerEmail,self.currentUserEmail,self.deviceTokenbyself,self.currentFcmToken)
                                    self.addHistory(titleNameEmail: callerEmail, email: self.currentUserEmail, deviceToken: self.deviceTokenbyself, fcmToken: self.currentFcmToken)
                                    print(self.currentUserEmail,callerEmail,callerDeviceToken,callerFCMToken)
                                    self.addHistory(titleNameEmail: self.currentUserEmail, email: "\(callerEmail)", deviceToken: "\(callerDeviceToken)",fcmToken: "\(callerFCMToken)")
                                }
                            }
                            
                        }
                    }
                }
            }
        
        }
    }
    
    func tapEndCall(){
        
        
        self.callCenter.EndCall()
        self.dataConnection?.close()
        self.mediaConnection?.close()
        self.changeConnectionStatusUI(connected: false)
        
    }

    func changeConnectionStatusUI(connected:Bool){
        UserDefaults.standard.set(connected, forKey: isConnectedState)
        print("CONNECTEDCONDITION",connected)
        //self.endCallButton.isEnabled = true
        
        if isFromEmailListVC {
            if isStartCalled && connected {
                self.durationTimeLB.isHidden = false
                self.removeAnnimation()
                timer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(showDurationTime(_:)),
                                             userInfo: nil,
                                             repeats: true)
                
            } else {
                self.durationTimeLB.isHidden = true
                self.animate()
                timer.invalidate()
                
            }
        } else {
            if isFromNoti {
                
            } else {
                if connected {
                    self.durationTimeLB.isHidden = false
                    timer = Timer.scheduledTimer(timeInterval: 1.0,
                                                 target: self,
                                                 selector: #selector(showDurationTime(_:)),
                                                 userInfo: nil,
                                                 repeats: true)
                } else {
                  //  self.durationTimeLB.isHidden = true
                    timer.invalidate()
                }
            }
        }
        
       
        
       
    }
    
    
    
   
    
    
    func changeViewController(){
        
        
        let main = UIStoryboard.init(name: "Main", bundle: nil)
        let rootVC = main.instantiateViewController(withIdentifier: "userListNav")
        rootVC.modalPresentationStyle = .fullScreen
        self.present(rootVC, animated: true)
    }
}

// MARK: skyway

extension TestViewController {

    func setup(){
        
        
        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = self.skywayAPIKey
        option.domain = self.skywayDomain

        peer = SKWPeer(options: option)
        

        if let _peer = peer {
            
            self.setupPeerCallBacks(peer: _peer)
            self.setupStream(peer: _peer)
            
            
        }else{
            let alert = UIAlertController(title: "エラー", message: "PeerのOpenに失敗しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func setupStream(peer:SKWPeer){
        
        SKWNavigator.initialize(peer);
        let constraints:SKWMediaConstraints = SKWMediaConstraints()
        self.localStream = SKWNavigator.getUserMedia(constraints)
       // self.localStream?.addVideoRenderer(self.localStreamView, track: 0)
        
        
    }
    
    

    func call(targetPeerId:String){
        
        
       
        let option = SKWCallOption()
        if self.localStream != nil {
        if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
            
            self.mediaConnection = mediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
        }else{
            print("failed to call :\(targetPeerId)")
        }
    }
            
    }
    
  

    func connect(targetPeerId:String){
       
        //self.callApple()
        if self.receiverDeviceToken == "android" {
            self.sendFCMPushNotificationAndroid()
            
        } else {
            self.sendFCMPushNotificationIOS()
        }
       
        
    }
    
    func sendEndCallNotification(){
        
        print("sendEndCallNotification")
        if isFromEmailListVC {
            
           // self.postEndCallNoti(deviceToken: self.receiverDeviceToken)
            if self.receiverDeviceToken == "android" {
                self.sendFCMEndCallPushNotificationAndroid(deviceToken: self.receiverDeviceToken, fcmToken:self.receiverFCMToken, isFromStarter: "true")
            } else {
                self.sendFCMEndCallPushNotificationIOS(deviceToken: self.receiverDeviceToken, fcmToken:self.receiverFCMToken, isFromStarter: "true")
            }
            
          
            
        } else {
            if let callerDeviceToken = UserDefaults.standard.object(forKey: "callerDeviceToken") as? String {
                if let callerFCMToken = UserDefaults.standard.object(forKey: "callerFCMToken") as? String {
                    // self.postEndCallNoti(deviceToken: callerDeviceToken)
                    if callerDeviceToken == "android" {
                        self.sendFCMEndCallPushNotificationAndroid(deviceToken: callerDeviceToken, fcmToken: callerFCMToken, isFromStarter: "false")
                    } else {
                        self.sendFCMEndCallPushNotificationIOS(deviceToken: callerDeviceToken, fcmToken: callerFCMToken, isFromStarter: "false")
                    }
                    
                    
                }
            }
            
        }
       
    }
    
    
    func sendFCMPushNotificationAndroid() {
        print(self.receiverFCMToken)
        
        var uuidString = String()
        if let u = UserDefaults.standard.object(forKey: "UUID") as? String {
            uuidString = u
        }
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : self.receiverFCMToken,
                                          // "notification" : ["title" : "IncomingCall", "body" : self.currentUserEmail],
                                           "content_available" : true,
                                           "data" : ["callerID":"\(self.currentPeerID)",
                                                     "UUIDSTRING":uuidString,
                                                     "callerEmail":self.currentUserEmail,
                                                                 "callerDeviceToken":"\(self.deviceTokenbyself)",
                                                     "callerFCMToken":self.currentFcmToken,
                                                                 "isEndCall":"false",
                                                     "receiveDeviceToken":self.receiverDeviceToken],
                                        
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA1u8DDoc:APA91bFfpDBqB7N4N5LU-eQFGlf-jG57AdoGvv8_YSr6DtCUqvAlYKg1mG4ZGCQkk8LPB2G0c2kVw7xPGooB8J6_3N2sRtfe8vVI3g_IejJ6CnSyVqmmZCuUYMzgPbJia6pnlPdk1aNP", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendFCMPushNotificationIOS() {
       
        
        var uuidString = String()
        if let u = UserDefaults.standard.object(forKey: "UUID") as? String {
            uuidString = u
        }
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : self.receiverFCMToken,
                                           "notification" : ["title" : "IncomingCall",
                                                             "body" : self.currentUserEmail],
                                           "content_available" : true,
                                           "data" : ["callerID":"\(self.currentPeerID)",
                                                     "UUIDSTRING":uuidString,
                                                     "callerEmail":self.currentUserEmail,
                                                     "callerDeviceToken":"\(self.deviceTokenbyself)",
                                                     "callerFCMToken":self.currentFcmToken,
                                                     "isEndCall":"false",
                                                     "receiveDeviceToken":self.receiverDeviceToken],]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA1u8DDoc:APA91bFfpDBqB7N4N5LU-eQFGlf-jG57AdoGvv8_YSr6DtCUqvAlYKg1mG4ZGCQkk8LPB2G0c2kVw7xPGooB8J6_3N2sRtfe8vVI3g_IejJ6CnSyVqmmZCuUYMzgPbJia6pnlPdk1aNP", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    
    
    
    func sendFCMEndCallPushNotificationAndroid(deviceToken:String,fcmToken:String,isFromStarter:String) {
        
        var uuidString = String()
        if let u = UserDefaults.standard.object(forKey: "UUID") as? String {
            uuidString = u
        }
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : fcmToken,
                                          // "notification" : ["title" : "EndCall", "body" : self.currentUserEmail],
                                           "content_available" : true,
                                           "data" : ["callerID":"BACK",
                                                     "UUIDSTRING":uuidString,
                                                     "callerEmail":self.currentUserEmail,
                                                     "callerDeviceToken":deviceToken,
                                                     "callerFCMToken":self.currentFcmToken,
                                                     "isEndCall":"true",
                                                     "receiveDeviceToken":deviceToken,
                                                     "isFromStarter":isFromStarter],]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA1u8DDoc:APA91bFfpDBqB7N4N5LU-eQFGlf-jG57AdoGvv8_YSr6DtCUqvAlYKg1mG4ZGCQkk8LPB2G0c2kVw7xPGooB8J6_3N2sRtfe8vVI3g_IejJ6CnSyVqmmZCuUYMzgPbJia6pnlPdk1aNP", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendFCMEndCallPushNotificationIOS(deviceToken:String,fcmToken:String,isFromStarter:String) {
        
        var uuidString = String()
        if let u = UserDefaults.standard.object(forKey: "UUID") as? String {
            uuidString = u
        }
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : fcmToken,
                                           "notification" : ["title" : "EndCall", "body" : self.currentUserEmail],
                                           "content_available" : true,
                                           "data" : ["callerID":"BACK",
                                                     "UUIDSTRING":uuidString,
                                                     "callerEmail":self.currentUserEmail,
                                                     "callerDeviceToken":deviceToken,
                                                     "callerFCMToken":self.currentFcmToken,
                                                     "isEndCall":"true","receiveDeviceToken":deviceToken,
                                                     "isFromStarter":isFromStarter],
                                        
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA1u8DDoc:APA91bFfpDBqB7N4N5LU-eQFGlf-jG57AdoGvv8_YSr6DtCUqvAlYKg1mG4ZGCQkk8LPB2G0c2kVw7xPGooB8J6_3N2sRtfe8vVI3g_IejJ6CnSyVqmmZCuUYMzgPbJia6pnlPdk1aNP", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    func sendFCMAnotherCallPushNotificationIOS(deviceToken:String,fcmToken:String) {
        
       
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : fcmToken,
                                           "notification" : ["title" : "EndCall", "body" : self.currentUserEmail],
                                           "content_available" : true,
                                           "data" : ["callerDeviceToken":deviceToken,
                                                     "isAnotherCall":"true"],
                                        
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA1u8DDoc:APA91bFfpDBqB7N4N5LU-eQFGlf-jG57AdoGvv8_YSr6DtCUqvAlYKg1mG4ZGCQkk8LPB2G0c2kVw7xPGooB8J6_3N2sRtfe8vVI3g_IejJ6CnSyVqmmZCuUYMzgPbJia6pnlPdk1aNP", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }

    func showPeersDialog(_ peer: SKWPeer, handler: @escaping (String) -> Void) {
        
        
        
        handler("\(self.receiverEmail)")
       
        
    }
    
    func addHistory(titleNameEmail:String,email:String,deviceToken:String,fcmToken:String){
        
        let seperateString = titleNameEmail.components(separatedBy: "@")
        let name = seperateString[0]
        //let name = titleNameEmail.replacingOccurrences(of: "@gmail.com", with: "")
        let param:[String:String] = ["connectedEmail":"\(email)",
                                     "connectedDeviceToken":"\(deviceToken)",
                                     "connectedFCMToken":"\(fcmToken)"]
         
       // ref = Database.database().reference()
       // ref.child("UsersHistory").child("\(name)").childByAutoId().setValue(param)
    }
}

// MARK: skyway callbacks

extension TestViewController{

    func setupPeerCallBacks(peer:SKWPeer) {

        
        // MARK: PEER_EVENT_ERROR
        peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR) { obj in
            
           // self.tap.text = "ERROR"
            if let error = obj as? SKWPeerError {
                print("\(error)")
            }
        }

        // MARK: PEER_EVENT_OPEN
        peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN) { obj in
            
            
            if let peerId = obj as? String{
               // self.tap.text = "\(peerId)"
                DispatchQueue.main.async {
                    self.currentPeerID = peerId
                    self.myPeerIdLabel.text = peerId
                    self.myPeerIdLabel.textColor = .clear
                  
                    
                    self.changeConnectionStatusUI(connected: false)
                }
                print("your peerId: \(peerId)")
                
                #if targetEnvironment(simulator)
                    // for sim only
                    #else
                    // for device
                   // self.uploadDeviceToken(peerID: peerId)
                    #endif
               
            }
        }

        // MARK: PEER_EVENT_CALL
        peer.on(SKWPeerEventEnum.PEER_EVENT_CALL) { obj in
            
            //self.tap.text = "CALL"
            if let connection = obj as? SKWMediaConnection{
                self.setupMediaConnectionCallbacks(mediaConnection: connection)
                self.mediaConnection = connection
                connection.answer(self.localStream)
            }
        }

        // MARK: PEER_EVENT_CONNECTION
        peer.on(SKWPeerEventEnum.PEER_EVENT_CONNECTION) { obj in
           // self.tap.text = "CONNECTION"
            if let connection = obj as? SKWDataConnection{
                if self.dataConnection == nil { // may be callee
                    //self.callCenter.IncomingCall(false, email: self.currentUserEmail)
                }
                self.dataConnection = connection
                self.setupDataConnectionCallbacks(dataConnection: connection)
            }
        }
    }

    func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){

        
        // MARK: MEDIACONNECTION_EVENT_STREAM
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM) { obj in
            if let msStream = obj as? SKWMediaStream{
                self.remoteStream = msStream
                DispatchQueue.main.async {
                    //self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                }
                
                self.changeConnectionStatusUI(connected: true)
                self.callCenter.Connected()
                self.callCenter.ConfigureAudioSession()
            }
        }

        // MARK: MEDIACONNECTION_EVENT_CLOSE
        mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE) { obj in
            if let _ = obj as? SKWMediaConnection{
                
                print("OTHERHANDCLOSE")
                
                DispatchQueue.main.async {
                    //self.remoteStream?.removeVideoRenderer(self.remoteStreamView, track: 0)
                    self.remoteStream = nil
                    self.dataConnection = nil
                    self.mediaConnection = nil
                }
                self.changeConnectionStatusUI(connected: false)
                self.callCenter.EndCall()
                
            }
        }
    }

    func setupDataConnectionCallbacks(dataConnection:SKWDataConnection){
        
       
        // MARK: DATACONNECTION_EVENT_OPEN
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_OPEN) { obj in
            self.changeConnectionStatusUI(connected: true)
        }

        // MARK: DATACONNECTION_EVENT_CLOSE
        dataConnection.on(SKWDataConnectionEventEnum.DATACONNECTION_EVENT_CLOSE) { obj in
            
            
            print("close data connection")
            self.dataConnection = nil
            self.changeConnectionStatusUI(connected: false)
            self.callCenter.EndCall()
            
        }
    }
}

// MARK: CXProviderDelegate

extension TestViewController: CXProviderDelegate {
    public func providerDidReset(_ provider: CXProvider) {

    }

    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        
        
        callCenter.ConfigureAudioSession()
        callCenter.Connecting()
        action.fulfill()
    }

    
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        UserDefaults.standard.set(true, forKey: isConnectedState)
        callCenter.ConfigureAudioSession()
        if let peer = self.dataConnection?.peer {
            
            self.call(targetPeerId: peer)
        } else {
            DispatchQueue.main.async {
                
                let state = UIApplication.shared.applicationState
                if state == .background || state == .inactive {
                    
                    // background
                    NotificationCenter.default.post(name: Notification.Name("SendNoti"), object: nil)
                    
                } else if state == .active {
                    
                   
                    // foreground
                 
                    NotificationCenter.default.post(name: Notification.Name("SendNoti"), object: nil)
                    //NotificationCenter.default.post(name: Notification.Name("AcceptCall"), object: nil)
                }
            }
           
            
        }
        
        action.fulfill()
    }

    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        UserDefaults.standard.set(false, forKey: isConnectedState)
        
        print("CXENDCALLFUNCTION")
        DispatchQueue.main.async {
            
            let state = UIApplication.shared.applicationState
            if state == .background || state == .inactive {
                
                // background
              
               // self.callCenter.EndCall()
                self.sendEndCallNotification()
                self.saveHistoryEndCall()
                self.tapEndCall()
                
            } else if state == .active {
                // foreground
              
               
            }
        }
      
        self.dataConnection?.close()
        self.mediaConnection?.close()
        action.fulfill()
    }
    
    public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
       print("MUTE")
    // This line is very important in this
        action.fulfill()
    // **** //
    }
}

extension TestViewController {
    func checkPermissionAudio() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .denied:
            let alert = UIAlertController(title: "マイクの許可", message: "アプリの設定画面からマイクの使用を許可してください", preferredStyle: .alert)
            let settings = UIAlertAction(title: "設定を開く", style: .default) { result in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            alert.addAction(settings)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { result in
                print("getAudioPermission: \(result)")
            }
        case .restricted:
            let alert = UIAlertController(title:nil, message: "マイクの使用が制限されています（通話することができません）", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        @unknown default:
            break
        }
    }
}




