//
//  SongQueueController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class SongQueueController {
    
    init() {
        SongQueueController.fetchSong(searchTerm: "John+Mayor") { (songs) in
            print(songs)
        }
    }
    
    var upNextQueue: [Song] = []
    var historyQueue: [Song] = []
    
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
    
    //when a user searches by song name, album name, or artist name, make a network call to pull JSON values and convert into a Song or  Album object
    
    static let baseURL = URL(string: "https://itunes.apple.com/search")
    //static let endpoint = baseURL?.appendingPathExtension("json")
    
    static func fetchSong(searchTerm: String, completion: @escaping (_ songs: [Song]?)-> Void) {
        
        let urlParameters = ["term": "\(searchTerm)", "entity":"musicTrack"]
        
        guard let url = baseURL else { completion(nil) ; return }
        
        //call networkcontroller to get data from URL
        NetworkController.performRequest(for: url, httpMethodString: "GET", urlParameters: urlParameters) { (data, error) in
            
            
            //unwrap the data
            guard let data = data else {
                print("Error: no data returned from network")
                completion(nil)
                return
            }
            print(data)
            
            //check if error occurred
            if error != nil {
                print(error?.localizedDescription)
                completion(nil)
            }
            
            //no error but data returned, serialize the JSON data returned
            guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: AnyObject],
                let resultsArrayOfDict = jsonDictionary["results"] as? [[String: AnyObject]]
                else {
                    print("Error: Unable to serialize returned JSON data.")
                    completion(nil)
                    return
            }
            
            let songsArray = resultsArrayOfDict.flatMap{Song(dictionary: $0)}
            completion(songsArray)
            
        }
    }
    
}
