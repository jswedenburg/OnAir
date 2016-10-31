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
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.parent?.navigationItem.rightBarButtonItem = editButtonItem
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        SongQueueController.sharedController.upNextQueue.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .fade)
//    }

    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete 
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //we can rearrange values in our data holder/array here b/c rearranging the UI only affects UI, not the actual order of the values in the array
        let itemToMove: Song = SongQueueController.sharedController.upNextQueue[sourceIndexPath.row]
        SongQueueController.sharedController.upNextQueue.remove(at: sourceIndexPath.row)
        SongQueueController.sharedController.upNextQueue.insert(itemToMove, at: destinationIndexPath.row)
        
    }
    
    
    // MARK: Functions
    
    func updateTableView() {
        self.tableView.reloadData()
    }
    
}
