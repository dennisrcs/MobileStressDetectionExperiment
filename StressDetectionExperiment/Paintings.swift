//
//  Paintings.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 2/28/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import Foundation

class Paintings {
    
    static var paintings: Dictionary<String, String> = ["":""]
    
    init() {
        Paintings.paintings["session1_easy1"] = "image1"
        Paintings.paintings["session1_easy2"] = "image2"
        Paintings.paintings["session1_easy3"] = "image3"
        
        Paintings.paintings["session1_hard1"] = "image4"
        Paintings.paintings["session1_hard2"] = "image5"
        Paintings.paintings["session1_hard3"] = "image6"
        
        Paintings.paintings["session2_easy1"] = "image7"
        Paintings.paintings["session2_easy2"] = "image8"
        Paintings.paintings["session2_easy3"] = "image9"
        
        Paintings.paintings["session2_hard1"] = "image10"
        Paintings.paintings["session2_hard2"] = "image11"
        Paintings.paintings["session2_hard3"] = "image12"
        
        Paintings.paintings["session3_easy1"] = "image13"
        Paintings.paintings["session3_easy2"] = "image14"
        Paintings.paintings["session3_easy3"] = "image15"
        
        Paintings.paintings["session3_hard1"] = "image16"
        Paintings.paintings["session3_hard2"] = "image17"
        Paintings.paintings["session3_hard3"] = "image18"
        
        Paintings.paintings["session4_easy1"] = "image19"
        Paintings.paintings["session4_easy2"] = "image20"
        Paintings.paintings["session4_easy3"] = "image21"
        
        Paintings.paintings["session4_hard1"] = "image22"
        Paintings.paintings["session4_hard2"] = "image23"
        Paintings.paintings["session4_hard3"] = "image24"
    }
}
