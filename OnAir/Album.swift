//
//  Album.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class Album {
    
    let name: String
    let artist: String
    let collectionID: String
    let songs: [Song]
    
    init(name: String, artist: String, collectionID: String, songs: [Song]) {
        self.name = name
        self.artist = artist
        self.collectionID = collectionID
        self.songs = songs
    }
}
