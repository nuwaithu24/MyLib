//
//  CallCenter.swift
//  App
//
//  Created by Nu Wai Thu on 2022/10/27.
//

import Foundation
import AVFoundation
import CallKit
import UIKit



public class CallCenter: NSObject {

    private let controller = CXCallController()
    private var provider: CXProvider
    private var uuid = UUID()
    private var isStartCall = false
    
    

    init(supportsVideo: Bool) {
        let providerConfiguration = CXProviderConfiguration(localizedName: "SkyWay(CallKit)")
        providerConfiguration.includesCallsInRecents = false
        providerConfiguration.supportsVideo = false//supportsVideo
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.maximumCallsPerCallGroup = 1
        provider = CXProvider(configuration: providerConfiguration)
    }

    func setup(_ delegate: CXProviderDelegate) {
        
        provider.setDelegate(delegate, queue: nil)
    }

    func StartCall(_ hasVideo: Bool = false) {
        
        uuid = UUID()
        isStartCalled = true
        self.isStartCall = true
        UserDefaults.standard.set("\(uuid)", forKey: "UUID")
        let handle = CXHandle(type: .generic, value: "NWT")
       
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
     
        startCallAction.isVideo = hasVideo
        let transaction = CXTransaction(action: startCallAction)
        controller.request(transaction) { error in
            if let error = error {
                print("CXStartCallAction error: \(error.localizedDescription)")
            }
        }
    }

    /*func IncomingCall(_ hasVideo: Bool = false,email:String) {
       // self.ConfigureAudioSession()
        uuid = UUID()
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .emailAddress, value: "\(email)")
        update.hasVideo = hasVideo
        update.supportsDTMF = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsHolding = false
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                
                print("reportNewIncomingCall error: \(error.localizedDescription)")
            } else {
                
            }
           
        }
    }*/
    
    func nIncomingCall(_ hasVideo: Bool = false,email:String) {
        //self.ConfigureAudioSession()
        if let saveUuid = UserDefaults.standard.object(forKey: "ENDCALLUUID") as? String {
            
            let u = UUID(uuidString: saveUuid)
            print(u!,"ENDCALLUUIDnIncomingCall")
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .emailAddress, value: "\(email)")
        update.hasVideo = false//hasVideo
            update.supportsDTMF = false
            update.supportsGrouping = false
            update.supportsUngrouping = false
            update.supportsHolding = false
            provider.reportNewIncomingCall(with: u!, update: update) { error in
            
            print("SHOWINCOMINGCALLUI")
            if let error = error {
                
                print("reportNewIncomingCall error: \(error.localizedDescription)")
                
            }
            else {
                print("ACCEPT")
               
               
                let state = UIApplication.shared.applicationState
                if state == .active {
                        print("App in active")
                  //  NotificationCenter.default.post(name: Notification.Name("AcceptCall"), object: nil)
                   // UserDefaults.standard.removeObject(forKey: "ENDCALLUUID")
                    } else {
                        
                    }
               
            }
                
            }
        }
    }
    
    func activeReportCall(){
        
        
            
        self.provider.reportCall(with:self.uuid, endedAt: Date(), reason: .remoteEnded)
        
       
        
        
    }
    
    func reportCall(){
        
        
        
        if let saveUuid = UserDefaults.standard.object(forKey: "ENDCALLUUID") as? String {
            let u = UUID(uuidString: saveUuid)
            
            
            provider.reportCall(with: u!, endedAt: Date(), reason: .unanswered)
        } else {
            
            
        }
    }
    
    func closeFromCallKit(){
        
        if isStartCall {
           print("ISSTARTCALL")
            let laction = CXEndCallAction(call: uuid)
            let ltransaction = CXTransaction(action: laction)
            DispatchQueue.main.async {
                
                self.controller.request(ltransaction) { error in
                    if let error = error {
                        print("CXEndCallAction error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            self.reportCall()
        }
        
    }
    
    func EndCallForStartCall(){
        let laction = CXEndCallAction(call: uuid)
        let ltransaction = CXTransaction(action: laction)
        DispatchQueue.main.async {
            
            self.controller.request(ltransaction) { error in
                if let error = error {
                    print("CXEndCallAction error: \(error.localizedDescription)")
                } else {
                    print("SUCCESSEND")
                   
                    
                }
            }
        }
    }
    
   
    func EndCall() {
         
       
        NotificationCenter.default.post(name: Notification.Name("EndCall"), object: nil)
        
        if isStartCall {
           print("ISSTARTCALL")
            let laction = CXEndCallAction(call: uuid)
            let ltransaction = CXTransaction(action: laction)
            DispatchQueue.main.async {
                
                self.controller.request(ltransaction) { error in
                    if let error = error {
                        print("CXEndCallAction error: \(error.localizedDescription)")
                    } else {
                        print("SUCCESSEND")
                       
                        
                    }
                }
            }
            
        } else {
            
            
            if let saveUuid = UserDefaults.standard.object(forKey: "ENDCALLUUID") as? String {
                 
                 
                 print(saveUuid)
                 let u = UUID(uuidString: saveUuid)
                 print(u!,"ENDCALLUUIDENDCALLSAVEUID")
                let action = CXEndCallAction(call: u!)
                 let transaction = CXTransaction(action: action)
                
               
                    
                    self.controller.request(transaction) { error in
                        if let error = error {
                           
                            self.provider
                           
                            print("CXEndCallAction error: \(error.localizedDescription)hfiowhfeiowhie")
                            
                        } else {
                            print("SUCCESSEND")
                            
                            
                        }
                    }
                
                
                 
                
            } else {
                
                
                DispatchQueue.main.async {
                    let laction = CXEndCallAction(call: self.uuid)
                    let ltransaction = CXTransaction(action: laction)
                    self.controller.request(ltransaction) { error in
                        if let error = error {
                            print("CXEndCallAction error: \(error.localizedDescription)")
                        } else {
                            
                            print("SUCCESSEND")
                           
                        }
                    }
                }
              
            }
        }
        
        
        
      
    }

    func Connecting() {
       
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }

    func Connected() {
      
            provider.reportOutgoingCall(with: uuid, connectedAt: nil)
        
       
    }

    func ConfigureAudioSession() {
        // Setup AudioSession
       /* try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.duckOthers,.allowBluetooth,.allowBluetoothA2DP])
        try? AVAudioSession.sharedInstance().setMode(.default)
        try? AVAudioSession.sharedInstance().setActive(true)*/
        let session = AVAudioSession.sharedInstance()
       
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord,mode: .default, options: [.duckOthers,.allowBluetooth,.allowBluetoothA2DP,.allowAirPlay,.defaultToSpeaker])
            try session.setActive(true)
            try session.setMode(.voiceChat)
            try session.overrideOutputAudioPort(.none)
            try session.setPreferredSampleRate(44100.0)
            try session.setPreferredIOBufferDuration(0.005)
        }
        catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
       
       
            
    }
    
   
}

// MARK: DEBUG

extension CallCenter {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMediaServerReset),
                                               name: AVAudioSession.mediaServicesWereResetNotification,
                                               object: nil)
    }

    @objc func handleRouteChange(notification: Notification) {
        print("handleRouteChange: \(notification)")
    }

    @objc func handleInterruption(notification: Notification) {
        print("handleInterruption: \(notification)")
    }

    @objc func handleMediaServerReset(notification: Notification) {
        print("handleMediaServerReset: \(notification)")
    }
}

