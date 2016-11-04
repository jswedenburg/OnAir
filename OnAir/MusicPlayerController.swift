//
//  MediaPlayerController.swift
//  MediaPlayerTest
//
//  Created by Angel Contreras on 10/25/16.
//  Copyright © 2016 Angel Contreras. All rights reserved.
//

// TODO: use the NotificationObservers to allow the Broadcaster to be able to change songs from the control center.

import Foundation
import MediaPlayer

protocol MusicPlayerControllerPlaybackDelegate: class {
    func playBackDidChange(value: Bool)
}

protocol MusicPlayerControllerNowPlayingDelegate: class {
    func nowPlayingItemDidChange()
}


class MusicPlayerController{
    
    let systemPlayer = MPMusicPlayerController.systemMusicPlayer()
//    let systemPlayer = MPMusicPlayerController.systemMusicPlayer()
    
    /// Variable to log when the listener has pressed paused from an in app button or in the control center.
    private var timeWhenPaused: Date?
    
    /// Initialized with a notification observer used to call the delegate function when playbackstate has changed.
    
    var arrayOfTrackID = [String]()
    
    // MARK: - Delegate
    /// Delegate that is called when the user play, pauses, skips, or returns from the control center or when the respective functions are called.
    var delegate: MusicPlayerControllerPlaybackDelegate?
    
    /// Delegate that is called when the the nowPlayingItem changes.
    var nowPlayingDelegate: MusicPlayerControllerNowPlayingDelegate?
    
    // MARK: - Singleton
    static let sharedController = MusicPlayerController()
    
    /// Function to get the state of the system player
//    func getSystemPlayerState() -> MPMusicPlaybackState{
//        return systemPlayer.playbackState
//    }
    
    /// Function to get the state of the application player
    func getApplicationPlayerState() -> MPMusicPlaybackState{
        return systemPlayer.playbackState
    }
    
    func getApplicationPlayerPlaybackTime() -> TimeInterval{
        return self.systemPlayer.currentPlaybackTime
    }
    
    func setCurrentPlaybackTime(_ timeInterval: TimeInterval){
        systemPlayer.currentPlaybackTime = timeInterval
    }
    
    /// Called when the Notification observer finds the MPMusicPlayerControllerPlaybackStateDidChange notification
    @objc func playbackChange(){
        if !(systemPlayer.playbackState == MPMusicPlaybackState.playing){
            delegate?.playBackDidChange(value: true)
        } else {
            delegate?.playBackDidChange(value: false)
        }
        
    }
    
    @objc func nowPlayingChange(){
        self.nowPlayingDelegate?.nowPlayingItemDidChange()
    }
    
    // MARK: - Listener's Music Player Functions
    
    /// Sets a song or an array of songs with their trackIDs in the queue via a variadic parameter "id". When a new song or songs are set, the pause timer gets reset. Also, if the listener is still in pause, the timer begins from when the song is set in the queue.
    func setListenerQueueWith(id: String...){
        self.timeWhenPaused = nil
        systemPlayer.setQueueWithStoreIDs(id)
        if systemPlayer.playbackState == MPMusicPlaybackState.paused{
            self.timeWhenPaused = Date()
        }
    }
    
    
    /// Plays the application player. If the listener was in pause, it will begin playing from when paused was pressed plus the amount of time in the listener was in pause.
    func listenerPlay(){
        if let timeWhenPaused = timeWhenPaused{
            let timeInterval = Date().timeIntervalSince(timeWhenPaused)
            print(timeInterval)
            let currentPlayBacktime = systemPlayer.currentPlaybackTime
            systemPlayer.currentPlaybackTime = timeInterval + currentPlayBacktime
            systemPlayer.play()
            self.timeWhenPaused = nil
        } else {
            systemPlayer.play()
        }
    }
    
    /// Pauses the listener's application player and begins the pause timer to calculate where to start the song playbacktime when the listerner presses play.
    func listenerPause(){
        timeWhenPaused = Date()
        systemPlayer.pause()
    }
    
    // MARK: - Broadcaster's Music Player Functions
    /// Sets an array of stings of trackIDs for the broadcaster's application player.
    func setBroadcaterQueueWith(ids:[String]){
        print("Queue is set")
        systemPlayer.setQueueWithStoreIDs(ids)
    }
    
    /// Starts the broadcaster's application player to play
    func broadcaterPlay(){
        systemPlayer.play()
    }
    
    /// Pauses the broadcaster's application player
    func broadcasterPause(){
        systemPlayer.pause()
    }
    
    /// Starts playback of the next song in the queue of the broadcaster's application player; or, if the music player is not playing, designates the next song as the next to be played.
    func skip(){
        systemPlayer.skipToNextItem()
    }
    
    func stop(){
        systemPlayer.stop()
    }
    
}
