//
//  SearchResultsViewController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import QuartzCore

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
        tableView.separatorStyle = .none
    
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a background view to the table view
        let backgroundImage = UIImage(named: "Skylar")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        // no lines where there aren't cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        // center and scale background image
        imageView.contentMode = .scaleAspectFill
        searchBarCustomizeAppearance()
    }
    
    

    
    
    //MARK: - Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //pull the searchTerm text out of the search bar and assign it as the value of the searchTerm parameter in fetchMovie function
        guard let searchTerm = searchBar.text else { return }
        
        //make the API call the moment the user clicks the searchBarButton- CHECK WITH AUSTIN, THIS FUNCTION NEEDS TO JUST ACCEPT THE SEARCH TERM, NOT ALL OF THESE paraameters- song or albumn
        self.searchBar.resignFirstResponder()
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
        SearchController.fetchSong(searchTerm: searchTerm) { (songs) in
            guard let songs = songs else {
                DispatchQueue.main.async {
                    self.alertControllerForFailedSearch()
                }
                 return
            }
            DispatchQueue.main.async {
                self.albums = AlbumController.sharedController.displayAlbumFrom(songsArray: songs)
                self.songs = songs
                
            }
        }
    }
    
    
    //changing physical appearance of Search Bar
    func searchBarCustomizeAppearance()
    {
       
        self.searchBar.layer.backgroundColor = UIColor.clear.cgColor
        self.searchBar.layer.cornerRadius = 20.0
        self.searchBar.clipsToBounds = false
        self.searchBar.placeholder = "Search for an artist or a song"
        self.searchBar.barTintColor = .white
        self.searchBar.layer.borderColor = UIColor.white.cgColor
        
        //change the searchIcon
        self.searchBar.setImage(#imageLiteral(resourceName: "Microphone"), for: UISearchBarIcon.search, state: UIControlState.normal)
        
        //removes lines around searchBar
        searchBar.backgroundImage = UIImage()
    }
    

    
   //function to create a rounded corner
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 20.0)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        path.fill()
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
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
        //hides section header if there are no rows
        if tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        } else {
            if section == 0 {
                return "Songs"
            } else {
                return "Albums"
            }
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
        cell?.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.96])
        cell?.layer.frame = CGRect(x: 20, y: 10, width: self.view.frame.size.width - 20 , height: 86)
        cell?.layer.masksToBounds = true
        cell?.layer.cornerRadius = 5.0
        cell?.layer.shadowOffset = CGSize(width: -1, height: 1)
        cell?.layer.shadowOpacity = 0.5
        


        
        
        
//        cell?.layer.cornerRadius = 30
//        cell?.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.8])
//        cell?.frame = CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 44)
//        cell?.layer.masksToBounds = true
//        cell?.layer.shadowOffset = CGSize(width: -1, height: 1)
//        cell?.layer.shadowOpacity = 0.2
        
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
                SongQueueController.sharedController.addSongToUpNext(newSong: song)
            }
        } else {
            presentAlertController()
        }
        
    }
    

    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    
//        cell.contentView.frame = CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 66)
//        cell.contentView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.8])
//        cell.layer.masksToBounds = false
//        cell.layer.cornerRadius = 5.0
//        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
//        cell.layer.shadowOpacity = 0.2
//    
//    }
    
    func alertControllerForFailedSearch() {
        let alertController = UIAlertController(title: "Error", message: "Unable to search. Please try back later.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
        })
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
