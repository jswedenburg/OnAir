//
//  DataController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 11/9/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation
import MediaPlayer
import MultipeerConnectivity

class DataController {
    
    static let sharedController = DataController()
    
    var timeStamp = Date()
    
    var song: Song? {
        didSet {
            MusicPlayerController.sharedController.broadcaterPlay()
            sendPlayData()
            let songHasChanged = Notification.Name(rawValue: "SongHasChanged")
            NotificationCenter.default.post(name: songHasChanged, object: nil)
        }
    }
    
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    
    func sendPlayData() {
        timeStamp = Date()
        makeDataDictionary(instruction: "play") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
    }
    
    func sendPauseData() {
        timeStamp = Date()
        makeDataDictionary(instruction: "pause") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
        
    }
    
    func sendNextSongData() {
        makeDataDictionary(instruction: "next") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
    }
    
    func makeDataDictionary(instruction: String, completion: (_ messageDict: [String: Any]?)-> Void){
        guard let song = self.song else { return }
        let messageDict: [String: Any] = ["instruction": instruction, "playbackTime": MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime(), "timeStamp": Date(), "song": song.dictionaryRepresentation]
        
        completion(messageDict)
    }
    
    func sendDataToNew(peer: MCPeerID?){
        guard let peerID = peer else { return }
        print("new peer \(peerID.displayName)")
        
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            sendPlayData()
        } else {
            sendPauseData()
        }
       
    }
    
    @objc func nowPlayingItemChanged(){
        print(Date().timeIntervalSince(timeStamp))
//        if Date().timeIntervalSince(timeStamp) > 1 {
//            timeStamp = Date()
//            index = index + 1
//            print(index)
            SongQueueController.sharedController.addSongToHistoryFromUpNext()
            (MusicPlayerController.sharedController.getApplicationPlayerState() == .playing) ? self.sendPlayData() : self.sendPauseData()
        
//        }
    }
    
}
