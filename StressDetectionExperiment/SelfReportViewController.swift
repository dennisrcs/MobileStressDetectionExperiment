//
//  SelfReportViewController.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 2/4/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import UIKit

class SelfReportViewController: UIViewController {
    
    // ScrollView
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Slider
    @IBOutlet weak var mentalDemandSlider: UISlider!
    @IBOutlet weak var physicalDemandSlider: UISlider!
    @IBOutlet weak var temporalDemandSlider: UISlider!
    @IBOutlet weak var performanceSlider: UISlider!
    @IBOutlet weak var effortSlider: UISlider!
    @IBOutlet weak var frustrationSlider: UISlider!
    
    var defaults = UserDefaults.standard
    
    // Member
    var pressedValenceButton: UIButton?
    var pressedValenceValue: Int = -1
    
    var pressedArousalButton: UIButton?
    var pressedArousalValue: Int = -1
    
    // Valence onClick methods
    @IBAction func onClickValence1Button(_ sender: UIButton) {
        updateCurrentValenceButton(sender, 1)
    }
    
    @IBAction func onClickValence2Button(_ sender: UIButton) {
        updateCurrentValenceButton(sender, 2)
    }
    
    @IBAction func onClickValence3Button(_ sender: UIButton) {
        updateCurrentValenceButton(sender, 3)
    }
    
    @IBAction func onClickValence4Button(_ sender: UIButton) {
        updateCurrentValenceButton(sender, 4)
    }
    
    @IBAction func onClickValence5Button(_ sender: UIButton) {
        updateCurrentValenceButton(sender, 5)
    }
    
    @IBAction func onClickValence6Button(_ sender: UIButton) {
        updateCurrentValenceButton(sender, 6)
    }
    
    @IBAction func onClickValence7Button(_ sender: UIButton) {
        updateCurrentValenceButton(sender, 7)
    }
    
    // Arousal onClick methods
    @IBAction func onClickArousal1Button(_ sender: UIButton) {
        updateCurrentArousalButton(sender, 1)
    }
    
    @IBAction func onClickArousal2Button(_ sender: UIButton) {
        updateCurrentArousalButton(sender, 2)
    }
    
    @IBAction func onClickArousal3Button(_ sender: UIButton) {
        updateCurrentArousalButton(sender, 3)
    }
    
    @IBAction func onClickArousal4Button(_ sender: UIButton) {
        updateCurrentArousalButton(sender, 4)
    }
    
    @IBAction func onClickArousal5Button(_ sender: UIButton) {
        updateCurrentArousalButton(sender, 5)
    }
    
    @IBAction func onClickArousal6Button(_ sender: UIButton) {
        updateCurrentArousalButton(sender, 6)
    }
    
    @IBAction func onClickArousal7Button(_ sender: UIButton) {
        updateCurrentArousalButton(sender, 7)
    }
    
    @IBAction func onMentalDemandSliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(mentalDemandSlider.value)), animated: true)
    }
    
    @IBAction func onPhysicalDemandSliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(physicalDemandSlider.value)), animated: true)
    }
    
    @IBAction func onTemporalDemandSliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(temporalDemandSlider.value)), animated: true)
    }
    
    @IBAction func onPerformanceSliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(performanceSlider.value)), animated: true)
    }
    
    @IBAction func onEffortSliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(effortSlider.value)), animated: true)
    }
    
    @IBAction func onFrustrationSliderChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(frustrationSlider.value)), animated: true)
    }
    
    func updateCurrentValenceButton(_ button: UIButton, _ value: Int) {
        if pressedValenceButton != nil {
            pressedValenceButton!.layer.borderWidth = 0
            pressedValenceButton!.layer.borderColor = UIColor.clear.cgColor
        }
        
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.black.cgColor
        
        pressedValenceButton = button
        pressedValenceValue = value
    }
    
    func updateCurrentArousalButton(_ button: UIButton, _ value: Int) {
        if pressedArousalButton != nil {
            pressedArousalButton!.layer.borderWidth = 0
            pressedArousalButton!.layer.borderColor = UIColor.clear.cgColor
        }
        
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.black.cgColor
        
        pressedArousalButton = button
        pressedArousalValue = value
    }
    
    @IBAction func onClickDoneButton(_ sender: UIButton) {
        
        var data:Dictionary<String, Int>!
        
        do {
            data = try prepareQuestionnaireData()
        } catch {
            let alert = UIAlertController(title: "Form Incomplete", message: "Please, make sure to fill out all items before submitting", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let round = defaults.integer(forKey: "round")
        let easyFirst = defaults.bool(forKey: "isEasyFirst")
        let easyOrHard = ((easyFirst && round == 2) ||
                          (easyFirst && round == 3) ||
                          (!easyFirst && round == 4) ||
                          (!easyFirst && round == 5)) ? "easy" : "hard"
        var SAMName = ""
        
        switch round {
        case 2:
            SAMName = "SAM_CWT_" + easyOrHard
            defaults.set(data, forKey: SAMName)
            loadWritingTask()
            break
        case 3:
            SAMName = "SAM_typing_" + easyOrHard
            defaults.set(data, forKey: SAMName)
            loadVideoTask()
            break
        case 4:
            SAMName = "SAM_CWT_" + easyOrHard
            defaults.set(data, forKey: SAMName)
            loadWritingTask()
            break
        case 5:
            SAMName = "SAM_typing_" + easyOrHard
            defaults.set(data, forKey: SAMName)
            loadEndScreen()
            break
        default:
            // do nothing
            break
        }
    }
    
    func prepareQuestionnaireData() throws -> Dictionary<String, Int> {
        
        if pressedArousalValue == -1 || pressedValenceValue == -1 {
            throw SelfReportIncompleteError.incompleteError("Valence or Arousal not filled out")
        }
        
        var quest = ["arousal" : Int(pressedArousalValue)]
        quest["valence"] = Int(pressedValenceValue)
        quest["mentalDemand"] = Int(mentalDemandSlider.value)
        quest["physicalDemand"] = Int(physicalDemandSlider.value)
        quest["temporalDemand"] = Int(temporalDemandSlider.value)
        quest["performance"] = Int(performanceSlider.value)
        quest["effort"] = Int(effortSlider.value)
        quest["frustration"] = Int(frustrationSlider.value)
        
        return quest
    }
    
    func loadWritingTask() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "WritingTaskController") as! WritingTaskController
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func loadVideoTask() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func loadEndScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "EndExperimentViewController") as! EndExperimentViewController
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
