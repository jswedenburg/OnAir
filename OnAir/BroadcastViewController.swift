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
    
    var isAdvertising = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        MPCManager.sharedController.delegate = self
        MPCManager.sharedController.advertiser.startAdvertisingPeer()
        MPCManager.sharedController.browser.startBrowsingForPeers()
    }
    
    @IBAction func broadcastButtonPressed(sender: UIButton) {
    
        if self.isAdvertising {
            sender.titleLabel?.text = "Start Advertising"
            MPCManager.sharedController.advertiser.stopAdvertisingPeer()
            self.isAdvertising = false
        } else {
            sender.titleLabel?.text = "Stop Advertising"
        }
    }
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
    
    func connectedWithPeer(peerID: MCPeerID) {
        //perform segue to mediaPlayer
    }
}
