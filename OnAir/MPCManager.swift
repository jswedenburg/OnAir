  //
  //  MPCManager.swift
  //  OnAir
  //
  //  Created by Jake SWEDENBURG on 10/25/16.
  //  Copyright © 2016 Jake Swedenbug. All rights reserved.
  //
  
  import Foundation
  import MultipeerConnectivity
  import UIKit
  
  protocol MPCManagerDelegate {
    
    func foundPeer()
    
    func lostPeer()
    
    func connectedWithPeer(peerID: MCPeerID)
    
    func disconnectWithPeer(peerID: MCPeerID)
    
  }
  
  protocol GotDataFromBroadcaster {
    func dataReceivedFromBroadcast(data: Data)
  }
  
  protocol ConnectedPeerArrayChangedDelegate {
    func connectedPeersChanged(peerID: MCPeerID)
  }
  
  class MPCManager: NSObject , MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    static let sharedController = MPCManager()
    
    var dataDelegate: GotDataFromBroadcaster?
    
    var connectedDelegate: ConnectedPeerArrayChangedDelegate?
    
    var delegate: MPCManagerDelegate?
    
    var session: MCSession!
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers: [MCPeerID] = []
    
    var connectedPeers: [MCPeerID] = []
    
    static var isBrowsing: Bool = false {
        didSet {
            let name = Notification.Name(rawValue: "isBrowsingChanged")
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    var isAdvertising: Bool = false {
        didSet {
            let name = Notification.Name(rawValue: "isAdvertisingChanged")
            NotificationCenter.default.post(name: name, object: isAdvertising)
        }
    }

  	let serviceType = "on-air"
    
    override init(){
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: self.serviceType)
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: self.serviceType)
        advertiser.delegate = self
    }
    
    
    //MARK: Broswer Delegate
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        if foundPeers.contains(peerID){
            //Do not append
        } else {
            foundPeers.append(peerID)
        }
        
        
        delegate?.foundPeer()
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.index(of: peerID) {
            foundPeers.remove(at: index)
        }
        
        delegate?.lostPeer()
    }
    
    // Advertiser Delegate
    
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        invitationHandler(true, self.session)
        
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
    // Session Delegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            delegate?.connectedWithPeer(peerID: peerID)
            if connectedPeers.contains(peerID) == false {
                connectedPeers.append(peerID)
            }
            browser.stopBrowsingForPeers()
            MPCManager.isBrowsing = false
            print("Connected")
            connectedDelegate?.connectedPeersChanged(peerID: peer)
        case MCSessionState.connecting:
            print("Connecting")
        default:
            if connectedPeers.contains(peerID) == true {
                let index = connectedPeers.index(of: peerID)
                connectedPeers.remove(at: index!)
            }
            print("Disconnected")
            connectedDelegate?.connectedPeersChanged(peerID: peer)
            let name = Notification.Name(rawValue: "diconnected")
            NotificationCenter.default.post(name: name, object: nil)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.dataDelegate?.dataReceivedFromBroadcast(data: data)
        
    }
    
    
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) { }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) { }
    
    // MARK: Custom Helper Functions
    
    func sendData(dictionary: Dictionary<String, Any>, to peers: [MCPeerID]?) {
        let peers = peers ?? self.connectedPeers
        
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try session.send(dataToSend, toPeers: peers, with: .unreliable)
        } catch  {
            print("Sending Failed")
        }
    }
    
    //Disconnect from current session
    
    func disconnect() {
        self.session.disconnect()
    }
  }
