//
//  SearchResultsViewController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,   SongAddedToQueueDelegate {
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notification.Name(rawValue: "QueueHasChanged") , object: nil)
        
    }

    
    
    //MARK: - Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //pull the searchTerm text out of the search bar and assign it as the value of the searchTerm parameter in fetchMovie function
        guard let searchTerm = searchBar.text else { return }
        
        //make the API call the moment the user clicks the searchBarButton- CHECK WITH AUSTIN, THIS FUNCTION NEEDS TO JUST ACCEPT THE SEARCH TERM, NOT ALL OF THESE paraameters- song or albumn
        self.searchBar.resignFirstResponder()
        SearchController.fetchSong(searchTerm: searchTerm) { (songs) in
            guard let songs = songs else { return }
            DispatchQueue.main.async {
                self.albums = AlbumController.sharedController.displayAlbumFrom(songsArray: songs)
                self.songs = songs
                
            }
        }
    }
    
    func cellButtonTapped(cell: SongQueueTableViewCell) {
        
        if MPCManager.sharedController.isAdvertising {
            if cell.song?.isAdded == true {
                // remove song
                // check mark is now a  plus sign
                // cell.songIsAdded = false
                if cell.song != nil {
                    cell.song?.isAdded = false
                    SongQueueController.sharedController.removeSongFromUpNext(song: cell.song!)
                } else {
                    guard let album = cell.album else { return }
                    AlbumController.sharedController.removeSongsFromQueueFrom(album: album)
                }
                cell.isAddedButton?.setTitle("+", for: .normal)
            } else {
                // add song(s) to queue
                // plus sign is now a check
                // cell.songIsAdded = true
                
                if cell.song != nil {
                    guard let song = cell.song else { return }
                    song.isAdded = true
                    SongQueueController.sharedController.addSongToUpNext(newSong: song)
                } else {
                    guard let album = cell.album else { return }
                    AlbumController.sharedController.addSongsToQueueWith(album: album)
                }
                cell.isAddedButton?.setTitle("✓", for: .normal)
                
            }
        } else {
            presentAlertController()
        }
    
       
    }
    
    // MARK: Helper Functions
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func presentAlertController() {
        
        let alertController = UIAlertController(title: "Attention", message: "You must be broadcasting to play a song or add a song to queue", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    //MARK:- Table view data source function
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Songs"
        } else {
            return "Albums"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return songs.count
        } else {
            return albums.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongQueueTableViewCell
        cell?.delegate = self
        if indexPath.section == 0 {
            let song = songs[indexPath.row]
            cell?.album = nil
            cell?.updateCellWith(song: song)
            return cell ?? SongQueueTableViewCell()
        } else if indexPath.section == 1 {
            let album = self.albums[indexPath.row]
            cell?.song = nil
            cell?.updateCellWith(album: album)
            return cell ?? SongQueueTableViewCell()
        } else {
            return cell ?? SongQueueTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if MPCManager.sharedController.isAdvertising {
            if indexPath.section == 0 {
                let song = songs[indexPath.row]
                SongQueueController.sharedController.appendSongToTopOfQueue(song)
                MusicPlayerController.sharedController.broadcaterPlay()
            }
        } else {
            presentAlertController()
        }
        
    }
    
    
}
