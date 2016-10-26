//
//  SearchResultsViewController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    //MARK: - IB Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var songs: [Song] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    var albums: [Album] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //MARK: - Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //pull the searchTerm text out of the search bar and assign it as the value of the searchTerm parameter in fetchMovie function
        guard let searchTerm = searchBar.text else { return }
        
        //make the API call the moment the user clicks the searchBarButton- CHECK WITH AUSTIN, THIS FUNCTION NEEDS TO JUST ACCEPT THE SEARCH TERM, NOT ALL OF THESE paraameters- song or albumn
        
        SearchController.fetchSong(searchTerm: searchTerm) { (songs) in
            guard let songs = songs else { return }
            DispatchQueue.main.async {
                self.albums = AlbumController.sharedController.displayAlbumFrom(songsArray: songs)
                self.songs = songs
                self.resignFirstResponder()
            }
        }
    }
    
    
    //MARK:- Table view data source function
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongQueueTableViewCell
        let song = songs[indexPath.row]
        cell?.updateCellWith(song: song)
        return cell ?? SongQueueTableViewCell()
    }
    
    
}
