//
//  SearchResultsViewController.swift
//  OnAir
//
//  Created by Austin Van Alfen on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: - IB Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    //initialize an empty array to hold the song objects returned from the API call. Use didSet to observe the songs array each time there is a change and reload the table view
    var songs: [Song] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: - Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //pull the searchTerm text out of the search bar and assign it as the value of the searchTerm parameter in fetchMovie function
        guard let searchTerm = searchBar.text else { return }
        
        //make the API call the moment the user clicks the searchBarButton- CHECK WITH AUSTIN, THIS FUNCTION NEEDS TO JUST ACCEPT THE SEARCH TERM, NOT ALL OF THESE paraameters- song or albumn
        SongController.fetchSong(searchTerm: "\(searchTerm)") { (songs) in
            guard let songs = songs else { return }
            
            //pull back to the main thread
            DispatchQueue.main.async {
                //assign song returned from addSong function to the empty songs array
                self.songs = songs
                //go away keyboard
                self.resignFirstResponder()
            }
        }
        
    }
    
    
    //MARK:- Table view data source functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = songs.count
        }
        if section == 1 {
            rowCount = albums.count
        }
        return rowCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell
        let song = songs[indexPath.row]
        let section = indexPath.section
        cell?.updateCell(song: song)
        return cell ?? SongTableViewCell()
    }
    
    
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String!
    {
        
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
