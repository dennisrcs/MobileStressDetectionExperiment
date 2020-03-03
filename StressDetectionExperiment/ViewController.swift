//
//  ViewController.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 1/28/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var participantIdTxt: UITextField!
    @IBOutlet weak var congruentModelSwitch: UISwitch!
    @IBOutlet weak var sessionNumberTxt: UITextField!
    
    var sessionNumber:Int = 0
    var isCongruent:Bool = true
    var participantId:String = ""
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding tap gesture to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onClickDone(_ sender: Any) {
        sessionNumber = Int(sessionNumberTxt.text!)!
        isCongruent = congruentModelSwitch.isOn
        participantId = participantIdTxt.text!
        
        defaults.set(participantId, forKey: "participantId")
        defaults.set(sessionNumber, forKey: "sessionNumber")
        defaults.set(isCongruent, forKey: "isEasyFirst")
        defaults.set(1, forKey: "round")
    }
    
}

