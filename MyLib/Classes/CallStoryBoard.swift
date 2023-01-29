//
//  CallStoryBoard.swift
//  MyLib
//
//  Created by Nu Wai Thu on 2023/01/28.
//

import Foundation
public class callStoryBoard{
    
    var vc : TestViewController!
    
    public init(){
        
    }
    
    public func call(parentView:UIViewController,deviceToken:String,email:String,fcmToken:String,isFromEmailListView:Bool){
        
        print("HelloWorld")
        let frameBundle = Bundle(for: callStoryBoard.self)
          let path = frameBundle.path(forResource: "MyLib", ofType: "bundle")
          if #available(iOS 16.0, *) {
              let resBundle = Bundle(url: URL(filePath: path!))
              let storyBoard = UIStoryboard(name: "PodStoryBoard", bundle: resBundle)
              let vc = storyBoard.instantiateViewController(withIdentifier: "videoCall") as! TestViewController
              vc.receiverDeviceToken = deviceToken
              vc.receiverEmail = email
              vc.receiverFCMToken = fcmToken
              vc.isFromEmailListVC = isFromEmailListView
              vc.modalPresentationStyle = .fullScreen
              parentView.present(vc, animated: true)
          } else {
              // Fallback on earlier versions
              let bundleUrl = frameBundle.url(forResource: "MyLib", withExtension: "bundle")
              let resBundle = Bundle(url: bundleUrl!)
              let storyBoard = UIStoryboard(name: "PodStoryBoard", bundle: resBundle)
              let vc = storyBoard.instantiateViewController(withIdentifier: "videoCall") as! TestViewController
              vc.receiverDeviceToken = deviceToken
              vc.receiverEmail = email
              vc.receiverFCMToken = fcmToken
              vc.isFromEmailListVC = isFromEmailListView
              vc.modalPresentationStyle = .fullScreen
              parentView.present(vc, animated: true)
          }
        
        
    }
    
    public func getViewControllerFromNoti() -> TestViewController {
        
       
        let frameBundle = Bundle(for: callStoryBoard.self)
          let path = frameBundle.path(forResource: "MyLib", ofType: "bundle")
        if #available(iOS 16.0, *) {
            let resBundle = Bundle(url: URL(filePath: path!))
            let storyBoard = UIStoryboard(name: "PodStoryBoard", bundle: resBundle)
            self.vc = storyBoard.instantiateViewController(withIdentifier: "videoCall") as! TestViewController
            self.vc.isFromNoti = true
        
        }
        
        return vc
        
    }
    
    public func sendIncomingCall(){
        TestViewController.sharedInstance.callCenter = CallCenter(supportsVideo: false)
        TestViewController.sharedInstance.callCenter.setup(TestViewController.sharedInstance.self)
    }
    
}

