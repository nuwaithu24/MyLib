//
//  Global.swift
//  MyLib
//
//  Created by Nu Wai Thu on 2023/01/28.
//

import Foundation
import UIKit
import AudioToolbox

var isStartCalled = false

var isConnectedState = "ConnectedState"
var currentConnectedEmail = "CurrentConnectedEmail"

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

func timeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60

        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }

