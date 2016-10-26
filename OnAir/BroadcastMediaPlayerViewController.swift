//
//  BroadcastMediaPlayerViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class BroadcastMediaPlayerViewController: UIViewController {
    
    var playMode = true
    
    var followersArray: [MCPeerID] = []

    override func viewDidLoad() {
        super.viewDidLoad()

            }
    
    @IBAction func playButtonPressed(){
        if playMode{
            //playercontroller.pause
            sendPauseData()
            playMode = false
        } else {
            //Playercontroller.play
            sendPlayData()
            playMode = true
        }
        
    }
    
    @IBAction func nextButtonPressed() {
        //playercontroller.next
        sendNextSongData()
    }
    
    
    
    func sendPlayData() {
        let messageDict: [String: String] = ["instruction": "play"]
        MPCManager.sharedController.sendData(dictionary: messageDict, peerArray: followersArray)
    }
    
    func sendPauseData() {
        let messageDict: [String: String] = ["instruction": "pause"]
        //Playercontroller.play
        MPCManager.sharedController.sendData(dictionary: messageDict, peerArray: followersArray)
    }
    
    func sendNextSongData() {
        let messageDict: [String: String] = ["instruction": "next"]
        //Playercontroller.play
        MPCManager.sharedController.sendData(dictionary: messageDict, peerArray: followersArray)
    }
    
    
    
    
    

}
