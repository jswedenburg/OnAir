//
//  BroadCastViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class BroadcastViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        MPCManager.sharedController.advertiser.startAdvertisingPeer()
        MPCManager.sharedController.browser.startBrowsingForPeers()
        SongQueueController.fetchSong(searchTerm: "John Mayor") { (songs) in
            print(songs)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


// MARK: - TableView Delegate and Datasource
extension BroadcastViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MPCManager.sharedController.foundPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "broadcastCell", for: indexPath)
        
        let peer = MPCManager.sharedController.foundPeers[indexPath.row]
        cell.textLabel?.text = peer.displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Present ReceiverMusicPlayer
    }
    
}

extension BroadcastViewController: MPCManagerDelegate{
    func foundPeer(){
        tableView.reloadData()
    }
    
    func invitationWasReceived(fromPeer: String) {
        print("do something")
    }
}
