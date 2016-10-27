//
//  BroadCastViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DiscoveryViewController: UIViewController {
    
    
    @IBOutlet weak var startStopAdvertisingButton: UIButton!
    var isAdvertising = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        MPCManager.sharedController.delegate = self
        MPCManager.sharedController.browser.startBrowsingForPeers()
        
    }
    
    @IBAction func broadcastButtonPressed(sender: UIButton) {
    
        if self.isAdvertising {
            startStopAdvertisingButton.setTitle("Start Advertising", for: .normal)
            MPCManager.sharedController.advertiser.stopAdvertisingPeer()
            self.isAdvertising = false
        } else {
            startStopAdvertisingButton.setTitle("Stop Advertising", for: .normal)
            MPCManager.sharedController.advertiser.startAdvertisingPeer()
            self.isAdvertising = true
        }
    }
    
    
}


// MARK: - TableView Delegate and Datasource
extension DiscoveryViewController: UITableViewDelegate, UITableViewDataSource{
    
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
        let peer = MPCManager.sharedController.foundPeers[indexPath.row] as MCPeerID
        guard let session = MPCManager.sharedController.session else { return }
        MPCManager.sharedController.browser.invitePeer(peer, to: session, withContext: nil, timeout: 20)
        
    }
    
}

extension DiscoveryViewController: MPCManagerDelegate{
    
    func foundPeer(){
        tableView.reloadData()
    }
    
    
    
    func connectedWithPeer(peerID: MCPeerID) {
        print("Connected")
        
        //preform segue to receiverMP
    }
}
