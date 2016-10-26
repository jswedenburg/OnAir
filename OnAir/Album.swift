//
//  Album.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class Album {
    
    private let kAlbumName = "collectionName"
    private let kArtist = "artistName"
    private let kCollectionID = "collectionId"
    
    let albumName: String
    let artist: String
    let collectionID: String
    let songs: [Song]
    let albumCover: String
    
    init(albumName: String, artist: String, collectionID: String, songs: [Song], albumCover: String) {
        self.albumName = albumName
        self.artist = artist
        self.collectionID = collectionID
        self.songs = songs
        self.albumCover = albumCover
    }
    
//    init?(dictionary: [String:Any]) {
//        guard
//        let name = dictionary[]
//    }
}
