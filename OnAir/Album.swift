//
//  Album.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class Album: Equatable {
    
    private let kAlbumName = "collectionName"
    private let kArtist = "artistName"
    private let kCollectionID = "collectionId"
    
    let albumName: String
    let artist: String
    let collectionID: Int
    let albumCover: String
    
    init(albumName: String, artist: String, collectionID: Int, albumCover: String) {
        self.albumName = albumName
        self.artist = artist
        self.collectionID = collectionID
        self.albumCover = albumCover
    }
}

func ==(lhs: Album, rhs: Album) -> Bool {
    return lhs.collectionID == rhs.collectionID
}
