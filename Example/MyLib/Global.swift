//
//  Global.swift
//  MyLib_Example
//
//  Created by Nu Wai Thu on 2023/01/29.
//  Copyright © 2023 CocoaPods. All rights reserved.
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

public class MyURLSessionDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // `NSURLAuthenticationMethodClientCertificate`
        // indicates the server requested a client certificate.
        if challenge.protectionSpace.authenticationMethod
             != NSURLAuthenticationMethodClientCertificate {
                completionHandler(.performDefaultHandling, nil)
                return
        }
        
       
        guard let file = Bundle.main.url(forResource: "MyLibVOIP", withExtension: "p12"),
              let p12Data = try? Data(contentsOf: file) else {
            
            // Loading of the p12 file's data failed.
            completionHandler(.performDefaultHandling, nil)
            return
        }
            // Interpret the data in the P12 data blob with
            // a little helper class called `PKCS12`.
            let password = "123456" // Obviously this should be stored or entered more securely.
            let p12Contents = PKCS12(pkcs12Data: p12Data, password: password)
            guard let identity = p12Contents.identity else {
                // Creating a PKCS12 never fails, but interpretting th contained data can. So again, no identity? We fall back to default.
                completionHandler(.performDefaultHandling, nil)
                return
            }

            // In my case, and as Apple recommends,
            // we do not pass the certificate chain into
            // the URLCredential used to respond to the challenge.
            let credential = URLCredential(identity: identity,
                                       certificates: nil,
                                        persistence: .none)
            challenge.sender?.use(credential, for: challenge)
            completionHandler(.useCredential, credential)
        }
       
        
        
        
        
    
}

private class PKCS12 {
    let label: String?
    let keyID: NSData?
    let trust: SecTrust?
    let certChain: [SecTrust]?
    let identity: SecIdentity?

    /// Creates a PKCS12 instance from a piece of data.
    /// - Parameters:
    ///   - pkcs12Data:the actual data we want to parse.
    ///   - password:The password required to unlock the PKCS12 data.
    public init(pkcs12Data: Data, password: String) {
        let importPasswordOption: NSDictionary
          = [kSecImportExportPassphrase as NSString: password]
        var items: CFArray?
        let secError: OSStatus
          = SecPKCS12Import(pkcs12Data as NSData,
                            importPasswordOption, &items)
        guard secError == errSecSuccess else {
            if secError == errSecAuthFailed {
                NSLog("Incorrect password?")

            }
            fatalError("Error trying to import PKCS12 data")
        }
        guard let theItemsCFArray = items else { fatalError() }
        let theItemsNSArray: NSArray = theItemsCFArray as NSArray
        guard let dictArray
          = theItemsNSArray as? [[String: AnyObject]] else {
            fatalError()
          }
        func f<T>(key: CFString) -> T? {
            for dict in dictArray {
                if let value = dict[key as String] as? T {
                    return value
                }
              }
            return nil
        }
        self.label = f(key: kSecImportItemLabel)
        self.keyID = f(key: kSecImportItemKeyID)
        self.trust = f(key: kSecImportItemTrust)
        self.certChain = f(key: kSecImportItemCertChain)
        self.identity = f(key: kSecImportItemIdentity)

    }
}

