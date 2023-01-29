//
//  VideoViewController.swift
//  MyLib
//
//  Created by Nu Wai Thu on 2023/01/28.
//

import UIKit
import Foundation

public class VideoViewController: UIViewController {
    
    
    @IBOutlet weak public var subView: UIView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .green
        let vc = UIView()
        vc.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        vc.backgroundColor = .brown
        self.view.addSubview(vc)
        self.subView.backgroundColor = .orange
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
