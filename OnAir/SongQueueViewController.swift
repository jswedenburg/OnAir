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
        
        self.tableView.separatorStyle = .none
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.parent?.navigationItem.rightBarButtonItem = editButtonItem
        self.parent?.parent?.navigationItem.rightBarButtonItem?.isEnabled = false
        self.parent?.parent?.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        
        // Add a background view to the table view
//        let backgroundImage = UIImage(named: "Skylar")
//        let imageView = UIImageView(image: backgroundImage)
//        // center and scale background image
//        imageView.contentMode = .scaleAspectFill
//        self.tableView.backgroundView = imageView
        self.tableView.reloadData()
    }
    
    
    // MARK: TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songQueueCell", for: indexPath) as? SongQueueTableViewCell else { return SongQueueTableViewCell() }
        cell.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.8])
        cell.layer.frame = CGRect(x: 20, y: 10, width: self.view.frame.size.width - 20 , height: 86)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 5.0
        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
        cell.layer.shadowOpacity = 0.5
        let song = songs[indexPath.row]
        cell.updateCellWith(song: song)
        return cell
    }
    
    
    //Delete function in editing mode
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            SongQueueController.sharedController.upNextQueue.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if (self.tableView.isEditing) {
            return UITableViewCellEditingStyle.delete
        }
        
        return UITableViewCellEditingStyle.none
    }
    
    
    //rearrange tableview cells in edit mode 
 
    
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
