//
//  VideoViewController.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 2/18/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIWebView!
    
    var videoTimer: Timer?
    var taskDuration: TimeInterval = 20.0

    override func viewDidLoad() {
        super.viewDidLoad()
        let randNum = arc4random_uniform(1000)
        let url = URL(string: "https://www.youtube.com/embed/1ZYbU82GVz4?start=\(randNum)")
        
        videoView.loadRequest(URLRequest(url: url!))
        
        videoTimer = Timer.scheduledTimer(timeInterval: taskDuration, target:self, selector: #selector(VideoViewController.wrapupVideoTask), userInfo: nil, repeats: false)
    }
    
    @objc func wrapupVideoTask() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CWTViewController") as! CWTViewController
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
