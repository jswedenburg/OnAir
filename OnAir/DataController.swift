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
            
            if song == nil {
                MusicPlayerController.sharedController.stop()
            }
            
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
    
    func sendStopData() {
        MusicPlayerController.sharedController.systemPlayer.stop()
        makeDataDictionary(instruction: "stop") { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: nil)
        }
    }
    
    func makeDataDictionary(instruction: String, completion: (_ messageDict: [String: Any]?)-> Void){
        if self.song == nil {
            let messageDict: [String: Any] = ["instruction": instruction, "playbackTime": MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime(), "timeStamp": Date(), "song": [:]]
            completion(messageDict)
        } else {
            let messageDict: [String: Any] = ["instruction": instruction, "playbackTime": MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime(), "timeStamp": Date(), "song": song!.dictionaryRepresentation]
            completion(messageDict)
        }
    }
    
    func sendDataToNew(peer: MCPeerID){
        print("new peer \(peer.displayName)")
        var instruction = ""
        
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            instruction = "play"
        } else {
            instruction = "pause"
        }
        makeDataDictionary(instruction: instruction) { (messageData) in
            guard let messageData = messageData else { return }
            MPCManager.sharedController.sendData(dictionary: messageData, to: [peer])
        }
    }
    
    @objc func nowPlayingItemChanged(){
        if SongQueueController.sharedController.upNextQueue.count == 0 {
            guard let nowPlayingItem = MusicPlayerController.sharedController.systemPlayer.nowPlayingItem, let songName = nowPlayingItem.title, let artistName = nowPlayingItem.artist else { return }
            SearchController.fetchSong(searchTerm: "\(songName) \(artistName)", completion: { (songs) in
                guard let songs = songs, let song = songs.first else { return }
                SongQueueController.sharedController.addSongToUpNext(newSong: song)
                
            })
             if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing {
                
                self.sendPlayData()
            } else {
                self.sendPauseData()
                
            }
        }
    }

    
}
