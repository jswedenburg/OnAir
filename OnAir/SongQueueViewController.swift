//
//  SongQueueViewController.swift
//  OnAir
//
//  Created by Chandi Abey  on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class SongQueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var songs: [Song] {
        return SongQueueController.sharedController.upNextQueue
    }
    
    // MARK: View

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: Notification.Name(rawValue: "QueueHasChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songQueueCell", for: indexPath) as? SongQueueTableViewCell else { return SongQueueTableViewCell() }
        let song = songs[indexPath.row]
        cell.updateCellWith(song: song)
        return cell
    }
    
    // MARK: Functions
    
    func updateTableView() {
        self.tableView.reloadData()
    }
    
}
