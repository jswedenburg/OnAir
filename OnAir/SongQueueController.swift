//
//  SongQueueController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

protocol SongQueueControllerDelegate: class {
    func songQueueHasChanged()
}

class SongQueueController {
    
    static let sharedController = SongQueueController()
    let historyQueueHasChanged = Notification.Name(rawValue: "historyQueueHasChanged")
    
    var upNextQueue: [Song] = [] {
        didSet {
            
            let arraySongIds = upNextQueue.map{"\($0.songID)"}
            MusicPlayerController.sharedController.setBroadcaterQueueWith(ids: arraySongIds )
            
            self.delegate?.songQueueHasChanged()
            let notification = Notification(name: Notification.Name(rawValue: "QueueHasChanged"))
            NotificationCenter.default.post(notification)
        }
    }
    
    weak var delegate: SongQueueControllerDelegate?
    
    var historyQueue: [Song] = []
    static var disableAddingSong = false
    
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
        NotificationCenter.default.post(name: historyQueueHasChanged, object: nil)
    }
    
    func isInQueue(song: Song) -> Bool {
        return upNextQueue.index(of: song) != nil
    }
    
    func appendSongToTopOfQueue(_ song: Song){
        if MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime() <= 1 { return }
        
        if MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime() > 0 {
            print(MusicPlayerController.sharedController.getApplicationPlayerPlaybackTime())
            addSongToHistoryFromUpNext()
        }
        
        if SongQueueController.sharedController.upNextQueue.index(of: song) != nil {
            let songIndex = SongQueueController.sharedController.upNextQueue.index(of: song)
            upNextQueue.remove(at: songIndex!)
            upNextQueue.insert(song, at: 0)
        } else {
            upNextQueue.insert(song, at: 0)
        }
        
    }
}
