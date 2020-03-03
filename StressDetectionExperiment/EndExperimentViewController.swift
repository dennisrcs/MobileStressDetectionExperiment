//
//  EndExperimentViewController.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 2/24/20.
//  Copyright © 2020 TAMU. All rights reserved.
//
import UIKit

class EndExperimentViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressBarPercentage: UILabel!
    
    var defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressBar.progress = 0.0
        
        let file = buildOutputFile()
    
        let participantId = defaults.integer(forKey: "participantId")
        let sessionNumber = defaults.integer(forKey: "sessionNumber")
        
        let filename = getDocumentsDirectory().appendingPathComponent("\(participantId)_\(sessionNumber).txt")
        
        do {
            try file.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            progressBar.progress = 1.0
            progressBarPercentage.text = "100 %"
            
            let content = try String(contentsOf: filename, encoding: String.Encoding.utf8)
            print(content)
            
        } catch {
            print("error saving file to disk")
        }
    }
    
    func buildOutputFile() -> String {
        let sessionNumber = defaults.integer(forKey: "sessionNumber")
        let participantId = defaults.integer(forKey: "participantId")
        let SAM_CWT_easy: Dictionary<String, Any> = defaults.dictionary(forKey: "SAM_CWT_easy")!
        let SAM_CWT_hard: Dictionary<String, Any> = defaults.dictionary(forKey: "SAM_CWT_hard")!
        let SAM_typing_easy: Dictionary<String, Any> = defaults.dictionary(forKey: "SAM_typing_easy")!
        let SAM_typing_hard: Dictionary<String, Any> = defaults.dictionary(forKey: "SAM_typing_hard")!
        
        let key:String = "text_session\(sessionNumber)_"
        
        let textEasy1:String = defaults.string(forKey: "\(key)easy1")!
        let textEasy2:String = defaults.string(forKey: "\(key)easy2")!
        let textEasy3:String = defaults.string(forKey: "\(key)easy3")!
        let textHard1:String = defaults.string(forKey: "\(key)hard1")!
        let textHard2:String = defaults.string(forKey: "\(key)hard2")!
        let textHard3:String = defaults.string(forKey: "\(key)hard3")!
        
        let file = "session number: \(sessionNumber) \n"
                + "participant id: \(participantId)\n"
                + "SAM_CWT_easy: \(parseDict(SAM_CWT_easy as! Dictionary<String, Int>))\n"
                + "SAM_CWT_hard: \(parseDict(SAM_CWT_hard as! Dictionary<String, Int>))\n"
                + "SAM_typing_easy: \(parseDict(SAM_typing_easy as! Dictionary<String, Int>))\n"
                + "SAM_typing_hard: \(parseDict(SAM_typing_hard as! Dictionary<String, Int>))\n"
                + "text_easy1: \(textEasy1)\n"
                + "text_easy2: \(textEasy2)\n"
                + "text_easy3: \(textEasy3)\n"
                + "text_hard1: \(textHard1)\n"
                + "text_hard2: \(textHard2)\n"
                + "text_hard3: \(textHard3)\n"
        
        return file
    }
    
    func parseDict(_ dic:Dictionary<String, Int>) -> String {
        let arousal = "\(Int(dic["arousal"]!))"
        let valence = "\(Int(dic["valence"]!))"
        let mentalDemand = "\(Int(dic["mentalDemand"]!))"
        let physicalDemand = "\(Int(dic["physicalDemand"]!))"
        let temporalDemand = "\(Int(dic["temporalDemand"]!))"
        let performance = "\(Int(dic["performance"]!))"
        let effort = "\(Int(dic["effort"]!))"
        let frustration = "\(Int(dic["frustration"]!))"
        
        let ret = "{\(arousal),\(valence),\(mentalDemand),\(physicalDemand),\(temporalDemand),\(performance),\(effort),\(frustration)}"
        
        return ret
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
