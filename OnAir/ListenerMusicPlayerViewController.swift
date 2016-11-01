//
//  ReceiverMusicPlayerViewController.swift
//  OnAir
//
//  Created by Angel Contreras on 10/25/16.
//  Copyright © 2016 Jake Swedenbug. All rights reserved.
//

import UIKit

class ListenerMusicPlayerViewController: UIViewController {
    
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // Will be needing for the broadcaster to send trackID, songName, and artistName.
    var previouslyPlayedSongs: [Song] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    var song: Song?{
        didSet{
            guard let song = oldValue else { return }
            previouslyPlayedSongs.append(song)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(dataReceived(notification:)), name: NSNotification.Name(rawValue: "receivedData"), object: nil)
    }
    
    func dataReceived(notification: Notification){
        // TODO: - unarchive data
        let dictionary = notification.userInfo
        guard let value = dictionary?["instruction"] as? String else { print("no value") ;return }
        
        switch value{
        case "play":
            print("play")
            MusicPlayerController.sharedController.broadcaterPlay()
        case "pause":
            print("pause")
            MusicPlayerController.sharedController.broadcasterPause()
        case "next":
            print("next")
            MusicPlayerController.sharedController.skip()
        default: ()
            
        }
        
    }
    @IBAction func muteButtonPressed(_ sender: UIButton) {
        if MusicPlayerController.sharedController.getApplicationPlayerState() == .playing{
            MusicPlayerController.sharedController.listenerPause()
        } else if MusicPlayerController.sharedController.getApplicationPlayerState() == .paused{
            MusicPlayerController.sharedController.listenerPlay()
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

extension ListenerMusicPlayerViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previouslyPlayedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previousSongCell", for: indexPath)
        
        
        
        return cell
    }
}
