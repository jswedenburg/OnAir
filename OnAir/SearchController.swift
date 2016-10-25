//
//  SearchController.swift
//  OnAir
//
//  Created by Chandi Abey  on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation
import UIKit


class SongSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    //MARK: - IB Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //initialize an empty array to hold the song objects returned from the API calll. Use didSet to observe the songs array each time there is a change and reload the table view
    var songs: [Song] = [] {
        didSet {
            self.tableView.reloadData()
        }
        
    }
    
    //MARK: -  Search Bar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //pull the searchTerm text out of the search bar and assign it as the value of the searchTerm parameter in fetchMovie function 
        guard let searchTerm = searchBar.text else { return }
        
        //make the API call the moment the user clicks the searchBarButton 
        SongController.fetchSong(searchTerm) { (song) in
            //since we made a call to the fetchSong function, we were pulled to the back thread. Pull us back to main thread with dispatch_async
            
            DispatchQueue.main.async {
                //assign the movies returned from the fetchSong function to the empty songs array we created above
                self.songs = songs
                //go away keyboard
                self.resignFirstResponder()
            }
        }
    }
    
    //MARK:- Table view data source functions 
        
    func numberOfSections(in tableView: UITableView) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }


}
