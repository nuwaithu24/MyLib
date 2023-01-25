//
//  ViewController.swift
//  MyLib
//
//  Created by nuwaithu24 on 01/26/2023.
//  Copyright (c) 2023 nuwaithu24. All rights reserved.
//

import UIKit
import MyLib

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lib = Logger()
        lib.outPutText(text: "Need to Success")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

