//
//  Song.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class Song {
    
    let name: String
    let artist: String
    let collectionID: String
    let trackDuration: Int
    let songID: String
    
    init(name: String, artist: String, collectionID: String, trackDuration: Int, songID: String) {
        self.name = name
        self.artist = artist
        self.collectionID = collectionID
        self.trackDuration = trackDuration
        self.songID = songID
    }
}
