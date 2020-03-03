//
//  CWTViewController.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 1/28/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class CWTViewController: UIViewController {
    
    // labels
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // buttons
    @IBOutlet weak var choice1Button: UIButton!
    @IBOutlet weak var choice2Button: UIButton!
    @IBOutlet weak var choice3Button: UIButton!
    @IBOutlet weak var choice4Button: UIButton!
    
    // progress bar
    @IBOutlet weak var progressBar: UIProgressView!
    
    // members
    var colors: [String] = []
    var colorsMap: [String: UIColor] = [:]
    var targetColorText:String = ""
    var targetColor:String = ""
    var chooseColor = true
    var answeredOnTime = false
    var elapsedTime = 0.0
    
    // entries
    var roundDuration = 3.0
    var taskDuration = 20.0
    var isCongruent = true
    var isEasyFirst = true
    var easyOrHard = ""
    var round = 0
    
    // timers
    var roundTimer:Timer?
    var progressBarTimer:Timer?
    
    var defaults = UserDefaults.standard
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Configuring fail buzzer
        if let asset = NSDataAsset(name:"fail") {
            do {
                player = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                player?.prepareToPlay()
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                } catch let error {
                    print(error.localizedDescription)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        // Loading game configs
        taskDuration = defaults.double(forKey: "taskDuration")
        round = defaults.integer(forKey: "round")
        isEasyFirst = defaults.bool(forKey: "isEasyFirst")
        isCongruent = ((isEasyFirst && round == 1) || (!isEasyFirst && round == 3))
        easyOrHard = (isCongruent) ? "easy" : "hard"
        
        // Filling set with predefined colors
        colors.append("Blue")
        colors.append("Red")
        colors.append("Green")
        colors.append("Purple")
        
        // Filling hash map
        colorsMap["Blue"] = UIColor.blue
        colorsMap["Red"] = UIColor.red
        colorsMap["Green"] = UIColor.green
        colorsMap["Purple"] = UIColor.purple
        
        // Initialize user interface elements
        initializeUIElements()
        
        // Setting round timer
        roundTimer = Timer.scheduledTimer(timeInterval: roundDuration, target: self, selector: #selector(CWTViewController.updateColors), userInfo: nil, repeats: true)
        
        // Setting progress bar timer
        progressBarTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector: #selector(CWTViewController.updateProgressBar), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgressBar() {
        elapsedTime += 0.1
        progressBar.progress = 1.0 - Float(elapsedTime) / Float(taskDuration)
        
        if elapsedTime >= taskDuration {
            roundTimer?.invalidate()
            progressBarTimer?.invalidate()
            
            defaults.set(round + 1, forKey: "round")
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelfReportViewController") as! SelfReportViewController
            self.present(nextViewController, animated: true, completion: nil)
        }
    }
    
    func initializeUIElements() {
        
        // initializing target label according to game mode
        colorLabel.text = "Red"
        if isCongruent {
            colorLabel.textColor = UIColor.red
        } else {
            colorLabel.textColor = UIColor.blue
        }
        
        // initialize buttons
        updateButtonTextAndColor(choice1Button, colors[0])
        updateButtonTextAndColor(choice2Button, colors[1])
        updateButtonTextAndColor(choice3Button, colors[2])
        updateButtonTextAndColor(choice4Button, colors[3])
        
        // load current color
        targetColor = colorLabel.text!
        
        // setting progress
        progressBar.progress = 1.0
    }
    
    func playFailSound() {
        player?.play()
        player?.prepareToPlay()
    }
    
    @objc func updateColors() {
        
        if !answeredOnTime {
            let currentScore:Int = Int(scoreLabel.text!)!
            scoreLabel.text = String(currentScore - 1)
            
            if !isCongruent {
                playFailSound()
            }
        }
        
        answeredOnTime = false
        let oldColors = colors
        
        // Update color combination
        repeat {
            colors.shuffle()
        } while !areDifferent(oldColors, colors)
        
        var randIndex:Int
        var newTargetColor:String
        
        // Update target
        repeat {
            randIndex = Int(arc4random_uniform(UInt32(colors.count)))
            newTargetColor = colors[randIndex]
        } while newTargetColor == targetColorText
        
        // Refreshing class member
        targetColorText = newTargetColor
        
        // Updating target's UI
        colorLabel.text = newTargetColor
        
        if isCongruent {
            colorLabel.textColor = colorsMap[newTargetColor]
            targetColor = newTargetColor
        } else {
            var differentTargetColor:String = ""
            repeat {
                randIndex = Int(arc4random_uniform(UInt32(colors.count)))
                differentTargetColor = colors[randIndex]
            } while newTargetColor == differentTargetColor
            colorLabel.textColor = colorsMap[differentTargetColor]
            targetColor = differentTargetColor
        }
        
        // Update buttons
        updateButtonTextAndColor(choice1Button, colors[0])
        updateButtonTextAndColor(choice2Button, colors[1])
        updateButtonTextAndColor(choice3Button, colors[2])
        updateButtonTextAndColor(choice4Button, colors[3])
        
        // Update instruction
        let probability = drand48()
        if probability < 0.5 {
            instructionLabel.text = "Choose Color"
            chooseColor = true
        } else {
            instructionLabel.text = "Choose Word"
            chooseColor = false
        }
    }
    
    func areDifferent(_ oldColors: [String], _ newColors: [String]) -> Bool {
        let result:Bool =   (oldColors[0] != newColors[0]) &&
                            (oldColors[1] != newColors[1]) &&
                            (oldColors[2] != newColors[2]) &&
                            (oldColors[3] != newColors[3])
        return result
    }
    
    func updateButtonTextAndColor(_ button:UIButton, _ color:String) {
        button.setTitle(color, for: .normal)
        if isCongruent {
            button.setTitleColor(colorsMap[color], for: .normal)
            paintBordersOnButtons(button, colorsMap[color]!)
        } else {
            button.setTitleColor(UIColor.black, for: .normal)
            paintBordersOnButtons(button, UIColor.black)
        }
    }
    
    func paintBordersOnButtons(_ button:UIButton, _ color:UIColor) {
        button.backgroundColor = .clear
        button.layer.borderWidth = 1.5
        button.layer.borderColor = color.cgColor
    }
    
    @IBAction func onClickChoice1Button(_ sender: UIButton) {
        handleOnClickChoice(sender)
    }
    
    @IBAction func onClickChoice2Button(_ sender: UIButton) {
        handleOnClickChoice(sender)
    }
    
    @IBAction func onClickChoice3Button(_ sender: UIButton) {
        handleOnClickChoice(sender)
    }
    
    @IBAction func onClickChoice4Button(_ sender: UIButton) {
        handleOnClickChoice(sender)
    }
    
    func handleOnClickChoice(_ sender: UIButton) {
        let buttonText:String = sender.currentTitle!
        let currentScore:Int = Int(scoreLabel.text!)!
        
        var isCorrect = false
        if chooseColor {
            isCorrect = (buttonText == targetColor)
            scoreLabel.text = (isCorrect) ? String(currentScore + 1) : String(currentScore - 1)
        } else {
            isCorrect = (buttonText == targetColorText)
            scoreLabel.text = (isCorrect) ? String(currentScore + 1) : String(currentScore - 1)
        }
        
        if !isCorrect && !isCongruent {
            playFailSound()
        }
        
        roundTimer?.invalidate()
        answeredOnTime = true
        updateColors()
        roundTimer = Timer.scheduledTimer(timeInterval: roundDuration, target: self, selector: #selector(CWTViewController.updateColors), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

