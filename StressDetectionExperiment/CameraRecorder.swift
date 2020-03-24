//
//  CameraRecorder.swift
//  StressDetectionExperiment
//
//  Created by Fabio Miyagawa on 3/24/20.
//  Copyright © 2020 TAMU. All rights reserved.
//

import UIKit
import AVFoundation

class CameraRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var captureSession:AVCaptureSession!
    var movieOutput:AVCaptureMovieFileOutput!
    
    func startRecording(_ videoFilename:String) {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        // Adding video input
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        
        // Configuring video output
        movieOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(movieOutput) else { return }
        captureSession.sessionPreset = .high
        captureSession.addOutput(movieOutput)
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent("\(videoFilename).mov")
        try? FileManager.default.removeItem(at: fileURL)
        
        // Start recording?
        captureSession.commitConfiguration()
        captureSession.startRunning()
        
        movieOutput.startRecording(to: fileURL, recordingDelegate: self)
    }
    
    // Stops the video recording and closes session
    func stopRecording() {
        movieOutput.stopRecording()
        captureSession.stopRunning()
    }
    
    // Triggered once recording is finished. Transfer file to photos album
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if error == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
        } else {
            print("Error: \(error!)")
        }
    }
    
}
