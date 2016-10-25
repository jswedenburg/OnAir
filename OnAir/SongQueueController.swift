//
//  SongQueueController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class SongQueueController {
    
    var upNextQueue: [Song] = []
    var historyQueue: [Song] = []
    
    func addSongToUpNext(name: String, artist: String, collectionID: String, trackDuration: Int, songID: String) {
        let newSong = Song(name: name, artist: artist, collectionID: collectionID, trackDuration: trackDuration, songID: songID)
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
}
