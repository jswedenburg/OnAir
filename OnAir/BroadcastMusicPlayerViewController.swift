//
//  BroadcastMediaPlayerViewController.swift
//  OnAir
//
//  Created by Jake SWEDENBURG on 10/26/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class BroadcastMusicPlayerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectedPeerArrayChangedDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var songAlbumImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    var animate = true
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    //MARK: Properties
    let player = MusicPlayerController.sharedController.systemPlayer
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        MPCManager.sharedController.connectedDelegate = self
        let songHasChanged = Notification.Name(rawValue: "SongHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewWithNewSong), name: songHasChanged, object: nil)
        setUpView()
        let name = Notification.Name(rawValue: "stoppedBroadcasting")
        NotificationCenter.default.addObserver(self, selector: #selector(setUpView), name: name, object: nil)
        
        
        
        
        playButton.titleLabel?.textColor = TeamMusicColor.ourColor
        nextButton.titleLabel?.textColor = TeamMusicColor.ourColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateViewWithNewSong()
        
        if MPCManager.sharedController.isAdvertising {
            NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            
        }
        
        
        self.tableView.reloadData()
        animateDiscTurn(imageView: songAlbumImageView, duration: 5.0, rotations: 1.0, repetition: 1.0)
    }
    
    
    //MARK: Actions
    @IBAction func playButtonPressed(){
        self.timeStamp = Date()
        
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            MusicPlayerController.sharedController.broadcasterPause()
            
        } else {
            MusicPlayerController.sharedController.broadcaterPlay()
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            NotificationCenter.default.addObserver(self, selector: #selector(self.nowPlayingItemChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            
        })
        
        
    }
    
    @IBAction func nextButtonPressed() {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        if SongQueueController.sharedController.upNextQueue.count == 1 {
            alert(title: "Out of songs!", message: "Add more songs to the queue")
        } else {
            SongQueueController.sharedController.addSongToHistoryFromUpNext()
            MusicPlayerController.sharedController.broadcaterPlay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                NotificationCenter.default.addObserver(self, selector: #selector(self.nowPlayingItemChanged), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
                
                })
            
        }
    }
    
    
    
    
    
    
    func setUpView() {
        songNameLabel.text = "Song Name"
        songArtistLabel.text = "Artist Name"
        songAlbumImageView.image = #imageLiteral(resourceName: "disc")
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(ok)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func connectedPeersChanged(peerID: MCPeerID) {
        self.tableView.reloadData()
        if MPCManager.sharedController.isAdvertising {
            print("connected peers changed \(peerID)")
            DataController.sharedController.sendDataToNew(peer: peerID)
        }
    }
    
    //MARK TableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MPCManager.sharedController.connectedPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peerCell", for: indexPath)
        cell.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.96])
        cell.layer.frame = CGRect(x: 20, y: 10, width: self.view.frame.size.width - 20 , height: 86)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 10.0
        cell.layer.shadowOffset = CGSize(width: -1, height: 1)
        cell.layer.shadowOpacity = 0.5
        
        if MPCManager.sharedController.connectedPeers.count > 0 {
            let peer = MPCManager.sharedController.connectedPeers[indexPath.row]
            cell.textLabel?.text = peer.displayName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Listening Peers"
    }
    
    func updateViewWithNewSong() {
        guard let song = DataController.sharedController.song else { return }
        self.songNameLabel.text = song.name
        self.songArtistLabel.text = song.artist
        songNameLabel.sizeToFit()
        songArtistLabel.sizeToFit()
        ImageController.imageForURL(imageEndpoint: song.image) { (image) in
            self.songAlbumImageView.image = image
            self.animate = false
        }
    }
    
    func animateDiscTurn(imageView: UIImageView, duration: Float, rotations: Float, repetition: Float){
        if animate{
            let rotaionAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
            let value = Float.pi * 2.0 * rotations * duration
            rotaionAnimation.toValue = NSNumber.init(value: value)
            rotaionAnimation.duration = CFTimeInterval(duration)
            rotaionAnimation.isCumulative = true
            rotaionAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            rotaionAnimation.repeatCount = repetition
            
            imageView.layer.add(rotaionAnimation, forKey: "rotationAnimation")
        }
    }
    
    var timeStamp = Date()
    
    
    func nowPlayingItemChanged(){
        if Date().timeIntervalSince(timeStamp) > 1 {
            self.timeStamp = Date()
            SongQueueController.sharedController.addSongToHistoryFromUpNext()
            updateViewWithNewSong()
            MusicPlayerController.sharedController.broadcaterPlay()
            
        }

    }
    
}
