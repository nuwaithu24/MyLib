//
//  AppDelegate.swift
//  MyLib
//
//  Created by nuwaithu24 on 01/26/2023.
//  Copyright (c) 2023 nuwaithu24. All rights reserved.
//

import UIKit
import PushKit
import CallKit
import FirebaseMessaging
import Firebase
import MyLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var backgroundTask: UIBackgroundTaskIdentifier?
    
    private let voipRegistry = PKPushRegistry(queue: nil)
    public func configurePushKit() {
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.configurePushKit()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: {_, _ in })
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "backgroundTask") {
                // Cleanup code should be written here so that you won't see the loader

                UIApplication.shared.endBackgroundTask(self.backgroundTask!)
            self.backgroundTask = UIBackgroundTaskInvalid
            }
      
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.set(false, forKey: isConnectedState)
        UserDefaults.standard.set("", forKey: currentConnectedEmail)
        if let id = UserDefaults.standard.object(forKey: "targetID") as? String{
            UserDefaults.standard.removeObject(forKey: "targetID")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        
    }
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        
        
        DispatchQueue.main.async {
            
            if let isConnected = UserDefaults.standard.object(forKey: isConnectedState) as? Bool {
                
                if isConnected {
                    
                } else {
                    
                    print("userinfo in background mode on-\(userInfo)")
                    if let notiDatas = userInfo as? [String:Any] {
                        
                        if let callerID = notiDatas["callerID"] as? String {
                            
                            if let callerEmail = notiDatas["callerEmail"] as? String {
                                
                                if let callerDeviceToken = notiDatas["callerDeviceToken"] as? String {
                                    
                                    if let isEndCall = notiDatas["isEndCall"] as? String {
                                        
                                        if let receiveDeviceToken = notiDatas["receiveDeviceToken"] as? String {
                                            if let UUIDSTRING = notiDatas["UUIDSTRING"] as? String {
                                                
                                                // callerFCMToken
                                                if let callerFCMToken = notiDatas["callerFCMToken"] as? String {
                                                    
                                                    
                                                    if isEndCall == "true" {
                                                        //isFromStarter
                                                        if isConnected {
                                                            if let currentConnectedEmail = UserDefaults.standard.object(forKey: currentConnectedEmail) as? String {
                                                                
                                                                if currentConnectedEmail == callerEmail {
                                                                    if let isFromStarter = notiDatas["isFromStarter"] as? String {
                                                                        
                                                                        
                                                                        self.postEndCallNoti(iOSdeviceToken: receiveDeviceToken, uuidString: UUIDSTRING, callerEmail: callerEmail, callerDeviceToken: callerDeviceToken,callerFCMToken:callerFCMToken, isFromStarter: isFromStarter)
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            
                                                            
                                                            
                                                            if let isFromStarter = notiDatas["isFromStarter"] as? String {
                                                                
                                                                
                                                                self.postEndCallNoti(iOSdeviceToken: receiveDeviceToken, uuidString: UUIDSTRING, callerEmail: callerEmail, callerDeviceToken: callerDeviceToken,callerFCMToken:callerFCMToken, isFromStarter: isFromStarter)
                                                            }
                                                        }
                                                    } else {
                                                        
                                                        
                                                        self.callAPNS(receiveDeviceToken: receiveDeviceToken, callerEmail: callerEmail, callerDeviceToken: callerDeviceToken, callerPeerID: callerID, uuidString: UUIDSTRING,callerFCMToken:callerFCMToken)
                                                        
                                                    }
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                    }
                    
                }
                
            } else {
                
                
                //print("userinfo in background mode on-\(userInfo)")
                if let notiDatas = userInfo as? [String:Any] {
                    
                    if let callerID = notiDatas["callerID"] as? String {
                        
                        if let callerEmail = notiDatas["callerEmail"] as? String {
                            
                            if let callerDeviceToken = notiDatas["callerDeviceToken"] as? String {
                                
                                if let isEndCall = notiDatas["isEndCall"] as? String {
                                    
                                    if let receiveDeviceToken = notiDatas["receiveDeviceToken"] as? String {
                                        
                                        if let UUIDSTRING = notiDatas["UUIDSTRING"] as? String {
                                            
                                            // callerFCMToken
                                            if let callerFCMToken = notiDatas["callerFCMToken"] as? String {
                                                
                                                
                                                if isEndCall == "true" {
                                                    //isFromStarter
                                                    if let isFromStarter = notiDatas["isFromStarter"] as? String {
                                                        
                                                        
                                                        /*  self.postEndCallNoti(iOSdeviceToken: receiveDeviceToken, uuidString: UUIDSTRING, callerEmail: callerEmail, callerDeviceToken: callerDeviceToken,callerFCMToken:callerFCMToken, isFromStarter: isFromStarter)*/
                                                    }
                                                } else {
                                                    
                                                    
                                                    self.callAPNS(receiveDeviceToken: receiveDeviceToken, callerEmail: callerEmail, callerDeviceToken: callerDeviceToken, callerPeerID: callerID, uuidString: UUIDSTRING,callerFCMToken:callerFCMToken)
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                        
                        
                    }
                }
                
            }
            //callApple()
            
        }

        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    var paramString = [String:String]()
    func callAPNS(receiveDeviceToken:String,callerEmail:String,callerDeviceToken:String,callerPeerID:String,uuidString:String,callerFCMToken:String){
       
        
        //backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "backgroundTask") {
                // Cleanup code should be written here so that you won't see the loader

               // UIApplication.shared.endBackgroundTask(self.backgroundTask!)
            //self.backgroundTask = UIBackgroundTaskIdentifier.invalid
           // }
      
        if let url = NSURL(string: "https://api.development.push.apple.com/3/device/\(receiveDeviceToken)") {
            
            //Database.database().reference().child("DEVICETOKEN").child("receiveToken").setValue(receiveDeviceToken)
             
                
                let config = URLSessionConfiguration.ephemeral
                config.urlCache = nil
            config.timeoutIntervalForRequest = TimeInterval(180)
            config.timeoutIntervalForResource = TimeInterval(180)
            
                let session = URLSession(configuration: config,delegate: MyURLSessionDelegate(),delegateQueue: nil)
                
                var request = URLRequest(url: url as URL)
                request.httpMethod = "POST"
            
               
            
                self.paramString = ["callerID":"\(callerPeerID)",
                        "UUIDSTRING":uuidString,
                        "callerEmail":callerEmail,
                                    "callerDeviceToken":"\(callerDeviceToken)",
                                    "isEndCall":"false",
                                    "callerFCMToken":callerFCMToken]
             print("HHHHHHHHHHHHH")
            print(self.paramString)
            print("HHHHHHHHHHHHH")
           
                    let jsonData = try? JSONSerialization.data(withJSONObject: paramString)
                    request.httpBody = jsonData
                

                let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    
                    let httpresponse = response as? HTTPURLResponse
                    let statusCode = httpresponse?.statusCode
                   
                    
                    if error != nil {
                        print("PUSHKIT error: \(error!.localizedDescription): \(error!)")
                        if (statusCode == -1005) {
                            print("ENTER-1005")
                           
                        }
                        //self.ref.child("ERROR").child("SNED").setValue(error!.localizedDescription)
                    } else if data != nil {
                        if let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                            print("Received data:\n\(str)")
                           
                        } else {
                            print("Unable to convert data to text")
                        }
                    }
                })

                task.resume()
          //  UIApplication.shared.endBackgroundTask(self.backgroundTask!)
          //  self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            } else {
                print("Unable to create NSURL")
            }
            
        
    }
    
    func postEndCallNoti(iOSdeviceToken:String,uuidString:String,callerEmail:String,callerDeviceToken:String,callerFCMToken:String,isFromStarter:String){
        DispatchQueue.main.async {
         
       
            
            
            
            if let url = NSURL(string: "https://api.push.apple.com/3/device/\(iOSdeviceToken)") {
                
                
                
                
                let config = URLSessionConfiguration.default
                
                
                let session = URLSession(configuration: config,delegate: MyURLSessionDelegate(),delegateQueue: nil)
                
                var request = URLRequest(url: url as URL)
                request.httpMethod = "POST"
                
                
                self.paramString = ["callerID":"BACK",
                                    "UUIDSTRING":uuidString,
                                    "callerEmail":callerEmail,
                                    "callerDeviceToken":callerDeviceToken,
                                    "isEndCall":"true",
                                    "callerFCMToken":callerFCMToken,
                                    "isFromStarter":isFromStarter]
                
                
                
                let jsonData = try? JSONSerialization.data(withJSONObject: self.paramString)
                request.httpBody = jsonData
                
                
                session.dataTask(with: request) { (data, response, error)  in
                    
                    
                    
                    
                    
                    let httpresponse = response as? HTTPURLResponse
                    let statusCode = httpresponse?.statusCode
                    
                    print(statusCode,"CODE")
                    
                    
                    
                    
                    if error != nil {
                        print("error: \(error!.localizedDescription): \(error!)")
                    } else if data != nil {
                        if let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) {
                            print("Received data:\n\(str)")
                            
                            
                        } else {
                            print("Unable to convert data to text")
                        }
                    }
                }.resume()
            }
                
                
            
            
            
        }
    }
       
    
    
  


}

extension  AppDelegate :  PKPushRegistryDelegate {
    
    func  pushRegistry (_ registry :  PKPushRegistry , didUpdate credentials :  PKPushCredentials , for type :  PKPushType ) {
        
        //generate device token
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
       print(deviceToken,"DeviceToken")
        
        
        
        
    }

    func  pushRegistry (_ registry :  PKPushRegistry , didInvalidatePushTokenFor type :  PKPushType ) {
         // Called when push notification settings are disabled in the Settings app, etc.
    }

    func  pushRegistry (_ registry :  PKPushRegistry , didReceiveIncomingPushWith payload :  PKPushPayload , for type :  PKPushType , completion :  @escaping () ->  Void ) {
          
        print("EnterPushKit")
        
        
             // Called when a VoIP push notification arrives
           
           let callerID = payload.dictionaryPayload["callerID"] as! String
            UserDefaults.standard.set(callerID, forKey: "targetID")
            
           
            
            
        
           
            let callerEmail = payload.dictionaryPayload["callerEmail"] as! String
            UserDefaults.standard.set(callerEmail, forKey: "notiCallerEmail")
            
            let callerDeviceToken = payload.dictionaryPayload["callerDeviceToken"] as! String
            UserDefaults.standard.set(callerDeviceToken, forKey: "callerDeviceToken")
            
          
            let  uuidString = payload.dictionaryPayload["UUIDSTRING"] as! String
            UserDefaults.standard.set(uuidString, forKey: "ENDCALLUUID")
        
            
            
            //callerFCMToken
            let callerFCMToken = payload.dictionaryPayload["callerFCMToken"] as! String
            UserDefaults.standard.set(callerFCMToken, forKey: "callerFCMToken")
            
            let isEndCall = payload.dictionaryPayload["isEndCall"] as! String
           
            
            
            
            
            if isEndCall == "true" {
                
              
                
                //isFromStarter
                let isFromStarter = payload.dictionaryPayload["isFromStarter"] as! String
                
                
                if isFromStarter == "true" {
                    
                    
                    
                 /*   VideoCallViewController.sharedInstance.callCenter.activeReportCall()
                    VideoCallViewController.sharedInstance.callCenter.reportCall()
                    NotificationCenter.default.post(name: Notification.Name("CallerEndCall"), object: nil)*/
                    
                    
                } else {
                    
                    
                    NotificationCenter.default.post(name: Notification.Name("CallerEndCall"), object: nil)
                }
               /* if let id = UserDefaults.standard.object(forKey: "targetID") as? String{
                    
                   
                    
                    if id == "BACK" {
                        
                        
                        //videoCallViewController.sharedInstance.tapEndCall()
                        NotificationCenter.default.post(name: Notification.Name("CallerEndCall"), object: nil)
                        
                    } else {
                        
                        
                        //videoCallViewController.sharedInstance.callCenter.activeReportCall()
                        videoCallViewController.sharedInstance.callCenter.reportCall()
                    }
                    
                }*/
                   
                
                
            } else {
                
                let state = UIApplication.shared.applicationState
                if state == .background || state == .inactive {
                    print("BACKGROUND")
                   /* let main = UIStoryboard.init(name: "Main", bundle: nil)
                    let rootVC = main.instantiateViewController(withIdentifier: "videoCall")
                    self.window?.rootViewController = rootVC
                    VideoCallViewController.sharedInstance.callCenter = CallCenterCallKit(supportsVideo: false)
                    VideoCallViewController.sharedInstance.callCenter.setup(VideoCallViewController.sharedInstance.self)
                    VideoCallViewController.sharedInstance.callCenter.nIncomingCall(false, email: callerEmail)*/
                 
                } else if state == .active {
                    
                    
                   print("ACTIVE")
                    let st = callStoryBoard()
                    let frameBundle = Bundle(for: callStoryBoard.self)
                      let path = frameBundle.path(forResource: "MyLib", ofType: "bundle")
                    if #available(iOS 16.0, *) {
                        
                        
                        let resBundle = Bundle(url: URL(filePath: path!))
                        let storyBoard = UIStoryboard(name: "PodStoryBoard", bundle: resBundle)
                        let rootVC = storyBoard.instantiateViewController(withIdentifier: "videoCall") as! TestViewController
                        rootVC.isFromNoti = true
                        
                        self.window?.rootViewController = rootVC
                        st.sendIncomingCall()
                    } else {
                        
                        let bundleUrl = frameBundle.url(forResource: "MyLib", withExtension: "bundle")
                        let resBundle = Bundle(url: bundleUrl!)
                        let storyBoard = UIStoryboard(name: "PodStoryBoard", bundle: resBundle)
                        let rootVC = storyBoard.instantiateViewController(withIdentifier: "videoCall") as! TestViewController
                        rootVC.isFromNoti = true
                        
                        self.window?.rootViewController = rootVC
                        st.sendIncomingCall()
                        
                    }
                    
                   /* let main = UIStoryboard.init(name: "Main", bundle: nil)
                    let rootVC = main.instantiateViewController(withIdentifier: "videoCall") as! VideoCallViewController
                    rootVC.isFromNoti = true
                    self.window?.rootViewController = rootVC
                    
                    VideoCallViewController.sharedInstance.callCenter = CallCenter(supportsVideo: false)
                    VideoCallViewController.sharedInstance.callCenter.setup(VideoCallViewController.sharedInstance.self)*/
               
                    //videoCallViewController.sharedInstance.callCenter.IncomingCall(false, email: callerEmail)
                }
                
               
               
            }
            
           
        
      
       
    }
}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // 通知を受け取った時に(開く前に)呼ばれるメソッド
   func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       
       print("ENTERFORCEGROUND1")
       
       let userInfo = notification.request.content

       print(userInfo)

       completionHandler([])
   }

    // 通知を開いた時に呼ばれるメソッド
   func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       print("ENTERFORCEGROUND2")
       
      /* defer { completionHandler() }
            let identity = response.notification.request.content.categoryIdentifier
            guard identity == "YesOrNO" else { return }*/
       let userInfo = response.notification.request.content.userInfo
      

       print(userInfo)

       completionHandler()
   }
    
    
    

}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        print("Firebase registration token: \(fcmToken)")
        Messaging.messaging().subscribe(toTopic: "/topics/skyWay") { error in
          
        }
        UserDefaults.standard.set(fcmToken, forKey: "FCMTOKEN")
       // configureCustomActions()
    }

   
}


