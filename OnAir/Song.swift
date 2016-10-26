//
//  Song.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

import Foundation

class Song: Equatable {
    
    //create keys to use in the failable initializer
    private let kSongName = "trackName"
    private let kArtist = "artistName"
    private let kAlbumID = "collectionId"
    private let kTrackDuration = "trackTimeMillis"
    private let kSongID = "trackId"
    private let kImage = "artworkUrl100"
    
    
    
    let name: String
    let artist: String
    let collectionID: Int
    let trackDuration: Int
    let songID: Int
    let image: String
    
    init(name: String, artist: String, collectionID: Int, trackDuration: Int, songID: Int, image: String) {
        self.name = name
        self.artist = artist
        self.collectionID = collectionID
        self.trackDuration = trackDuration
        self.songID = songID
        self.image = image
    }
    
    
    
    //Model Objects: failable initializer.
    
    init?(dictionary: [String: Any])
    {
        //first level dictionary- on the first level we have the bookName and array of song dictionaries
        guard let name = dictionary[kSongName] as? String,
            let artist = dictionary[kArtist] as? String,
            let collectionID = dictionary[kAlbumID] as? Int,
            let trackDuration = dictionary[kTrackDuration] as? Int,
            let songID = dictionary[kSongID] as? Int,
            let image = dictionary[kImage] as? String
            else { return nil }
        
        
        self.name = name
        self.artist = artist
        self.collectionID = collectionID
        self.trackDuration = trackDuration
        self.songID = songID
        self.image = image
    }
    
    
}

func ==(lhs: Song, rhs: Song) -> Bool {
    return lhs.songID == rhs.songID
}
