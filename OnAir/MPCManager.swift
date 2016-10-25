//
//  MPCManager.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MPCManagerDelegate {

    func foundPeer()
    
    func invitationWasReceived(fromPeer: String)

}

class MPCManager: NSObject , MCNearbyServiceBrowserDelegate {
    
    static let sharedController = MPCManager()
    
    var delegate: MPCManagerDelegate
    
    var session: MCSession!
    
    var peer: MCPeerID
    
    var browser: MCNearbyServiceBrowser
    
    var advertiser: MCNearbyServiceAdvertiser
    
    var foundPeers: [MCPeerID] = []
    
    var invitationHandler: ((Bool, MCSession?)->Void)!
    
    
    override init(){
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        //session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "onAir")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "onAir")
        //advertiser.delegate = self
        
        
        
    }
    
    
    //MARK: Broswer Delegate 
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        
        delegate.foundPeer()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer")
    }
    
    // Advertiser Delegate
    
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.invitationHandler = invitationHandler
        
        delegate.invitationWasReceived(fromPeer: peerID.displayName)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }

}
