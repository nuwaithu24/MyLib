//
//  ViewController.swift
//  MyLib
//
//  Created by nuwaithu24 on 01/26/2023.
//  Copyright (c) 2023 nuwaithu24. All rights reserved.
//

import UIKit
import MyLib
import Firebase

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
       // let lib = Logger()
      //  lib.outPutText(text: "Need to Success")
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showPodViewController(_ sender: Any) {
        
        let fcm = "dMypg5AUtU_4sZcbtFnwGA:APA91bGpuITPlESFjKLZINZ7rCC10eU0iS9rJHqixZGC-uHpyNYWCOFzGutjqjBHJBMHRuHrJ-p0L16wvpF18f69m9mnbLAhz2A2Vae04zt-1okJEmUYYPnuUWQLpgwJhl3xcvLwSCxT"
        let device = "3db45303757be8d007298d7541288be3c642fad09b0c6dc991c22d3a9e5f24a4"
        let email = "nu@gmail.com"
        let callFunc = callStoryBoard()
        callFunc.call(parentView: self, deviceToken:device , email: email, fcmToken: fcm, isFromEmailListView: true)
       // callFunc.call(parentView: self)
       /* let callFunc = callStoryBoard()
        callFunc.call()
        let frameBundle = Bundle(for: callStoryBoard.self)
        let path = frameBundle.path(forResource: "MyLib", ofType: "bundle")
        if #available(iOS 16.0, *) {
            let resBundle = Bundle(url: URL(filePath: path!))
            let storyBoard = UIStoryboard(name: "PodStoryBoard", bundle: resBundle)
            let vc = storyBoard.instantiateViewController(withIdentifier: "Video")
            self.present(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }*/
        
        
    }
}

