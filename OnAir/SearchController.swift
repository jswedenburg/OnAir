//
//  SearchController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation

class SearchController {
    
    static let lookupURL = URL(string: "https://itunes.apple.com/lookup")
    static let searchURL = URL(string: "https://itunes.apple.com/search")
    
    
    static func fetchAlbumSongsWith(id: Int, completion: @escaping (_ songs: [Song]?)-> Void) {
        
        let urlParameters = ["id":"\(id)", "entity":"song"]
        
        guard let url = lookupURL else { completion(nil) ; return }
        
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
    
    static func fetchSong(searchTerm: String, completion: @escaping (_ songs: [Song]?)-> Void) {
        
        let urlParameters = ["term": "\(searchTerm)", "entity":"musicTrack"]
        
        guard let url = searchURL else { completion(nil) ; return }
        
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
