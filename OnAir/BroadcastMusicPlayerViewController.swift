//
//  BroadcastMediaPlayerViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class BroadcastMusicPlayerViewController: UIViewController {
    
    var playMode = true
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

            }
    
    @IBAction func playButtonPressed(){
        if playMode{
            MusicPlayerController.sharedController.broadcasterPause()
            sendPauseData()
            playMode = false
        } else {
            MusicPlayerController.sharedController.broadcaterPlay()
            sendPlayData()
            playMode = true
        }
        
    }
    
    @IBAction func nextButtonPressed() {
        MusicPlayerController.sharedController.skip()
        sendNextSongData()
    }
    
    
    
    func sendPlayData() {
        let messageDict: [String: String] = ["instruction": "play"]
        MPCManager.sharedController.sendData(dictionary: messageDict)
    }
    
    func sendPauseData() {
        let messageDict: [String: String] = ["instruction": "pause"]
        MPCManager.sharedController.sendData(dictionary: messageDict)
    }
    
    func sendNextSongData() {
        let messageDict: [String: String] = ["instruction": "next"]
        MPCManager.sharedController.sendData(dictionary: messageDict)
    }
    
    
    
    
    

}
