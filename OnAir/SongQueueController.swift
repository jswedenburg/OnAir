//
//  SongQueueController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class SongQueueController {
    
    static let sharedController = SongQueueController()
    let historyQueueHasChanged = Notification.Name(rawValue: "historyQueueHasChanged")
    var oldSong: Song?
    
    var upNextQueue: [Song] = [] {
        didSet {
            let newSong = upNextQueue.first
            
            if upNextQueue.count > 0 && oldSong != newSong {
                DataController.sharedController.song = newSong
                let songIds = upNextQueue.map({"\($0.songID)"})
                MusicPlayerController.sharedController.setBroadcaterQueueWith(ids: songIds )
                if oldSong != nil {
                    historyQueue.append(oldSong!)
                }
                oldSong = newSong
            } else if upNextQueue.count == 0 {
                DataController.sharedController.song = nil
            }
            let notification = Notification(name: Notification.Name(rawValue: "QueueHasChanged"))
            NotificationCenter.default.post(notification)
        }
    }
    
    var historyQueue: [Song] = [] {
        didSet{
            NotificationCenter.default.post(name: historyQueueHasChanged, object: nil)
        }
    }
    
    func addSongToUpNext(newSong: Song) {
        upNextQueue.append(newSong)
    }
    
    func removeSongFromUpNext(song: Song) {
        guard let indexOfSong = upNextQueue.index(of: song) else { return }
        upNextQueue.remove(at: indexOfSong)
    }
    
    func addSongToHistoryFromUpNext() {
        guard let song = upNextQueue.first else { return }
        upNextQueue.remove(at: 0)
        historyQueue.insert(song, at: 0)
    }
    
    func isInQueue(song: Song) -> Bool {
        return upNextQueue.index(of: song) != nil
    }
    
    func appendSongToTopOfQueue(_ song: Song){
        let time = MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime()
        if time <= 1 { return }
        if upNextQueue.index(of: song) != nil {
            let songIndex = upNextQueue.index(of: song)
            upNextQueue.remove(at: songIndex!)
            upNextQueue.insert(song, at: 0)
        } else {
            upNextQueue.insert(song, at: 0)
        }
        
    }
}
