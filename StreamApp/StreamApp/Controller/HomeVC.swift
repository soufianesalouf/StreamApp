//
//  ViewController.swift
//  StreamApp
//
//  Created by Soufiane Salouf on 3/27/18.
//  Copyright © 2018 Soufiane Salouf. All rights reserved.
//

import UIKit
import AVFoundation

class HomeVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var actualDurationLbl: UILabel!
    @IBOutlet weak var fullDurationLbl: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var nowPlayingBarsImage: UIImageView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    
    
    //Variables
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    
    //Current song from list of songs
//    var listNum = 1
    
    //LIST OF Audio Files
//    var listOfSongs: [String] = ["AllOfMe.mp3","NtiSbabi.mp3", "TsalaLiyaSolde.mp3"]
    var songs : Songs!
    
    var currentSong = 0
//    var currentList = 0

    override func viewDidLoad() {
        songTitle.text = "Loading ..."
        super.viewDidLoad()
        importSongs()
        tableView.delegate = self
        tableView.dataSource = self
        playbackSlider!.minimumValue = 0
        setPlayer()
        //playOn()
    }
    
    func importSongs(){
        let path = Bundle.main.path(forResource: "Songs", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let data = try Data(contentsOf: url)
            self.songs = try JSONDecoder().decode(Songs.self, from: data)
        } catch {
            debugPrint(error)
        }
    }
    
    /* Function called when sliders is adjusted manually.
     */
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
        }
    }
    
    //setup avplayer avPlayerItem --> objects used to play audio files
    func setPlayer(){
        
        var url: URL!
        if USE_RADIO_URL {
            url = URL(string: RADIO_URL)
        } else {
            url = URL(string: songs.tracks[currentSong].url)
        }
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        
//        let index = IndexPath(row: currentSong, section: 0)
//        self.tableView.selectRow(at: index, animated: true, scrollPosition: UITableViewScrollPosition.middle)
//        tableView(self.tableView, didSelectRowAt: index)
        
        playerLayer=AVPlayerLayer(player: player!)
        playerLayer?.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
        self.view.layer.addSublayer(playerLayer!)
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        let mySecs = Int(seconds) % 60
        let myMins = Int(seconds / 60)
        
        let myTimes = String(myMins) + ":" + String(mySecs)
        fullDurationLbl.text = myTimes
        
        
        playbackSlider!.maximumValue = Float(seconds)
        playbackSlider!.isContinuous = false
//        playbackSlider!.tintColor = UIColor.green
        
        playbackSlider?.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
//        self.view.addSubview(playbackSlider!)
        
        //subroutine used to keep track of current location of time in audio file
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime())
                
                //comment out if you don't want continous play
                if(time == seconds && self.currentSong != self.songs.tracks.count - 1){
                    self.nextSong()
                }
                
                let mySecs2 = Int(time) % 60
                
                if(mySecs2 == 1){ //show title of song after 1 second
                    self.songTitle.text = self.songs.tracks[self.currentSong].title
                }
                let myMins2 = Int(time / 60)
                
                let myTimes2 = String(myMins2) + ":" + String(mySecs2)
                self.actualDurationLbl.text = myTimes2 //current time of audio track
                
                
                self.playbackSlider!.value = Float ( time )
            }
        }
    }
    
    //plays next song automatically when previous song finishes
    func nextSong(){
        songTitle.text = "Loading ..."
        if currentSong < songs.tracks.count - 1{
            currentSong = currentSong + 1
        } else {
            currentSong = 0
        }
        
        player!.pause()
        player = nil
        
        setPlayer()
        if player?.rate == 0
        {
            player!.play()
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
        }
    }
    
    @IBAction func previousBtnWasPressed(_ sender: Any) {
        songTitle.text = "Loading ..."
        if(currentSong > 0){
            currentSong = currentSong - 1
        } else {
            currentSong = songs.tracks.count - 1
        }
        player!.pause()
        player = nil
        setPlayer()
        if player?.rate == 0
        {
            player!.play()
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
        }
    }
    
    @IBAction func playPauseBtnWasPressed(_ sender: Any) {
        songTitle.text = songs.tracks[currentSong].title
        if player?.rate == 0
        {
            player!.play()
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
        } else {
            player!.pause()
            playPauseBtn!.setImage(UIImage(named: "btn-play.png"), for: UIControlState.normal)
        }
    }
    
    @IBAction func stopBtnWasPressed(_ sender: Any) {
        songTitle.text = "Streamming Stopped."
        if player?.rate == 0
        {
            
        } else {
            player!.pause()
            playPauseBtn!.setImage(UIImage(named: "btn-play.png"), for: UIControlState.normal)
        }
        player?.seek(to: CMTimeMake(0, 1))
    }
    
    @IBAction func nextBtnWasPressed(_ sender: Any) {
        songTitle.text = "Loading ..."
        if(currentSong < songs.tracks.count - 1){
            currentSong = currentSong + 1
        } else {
            currentSong = 0
        }
        
        player!.pause()
        player = nil
        setPlayer()
        if player?.rate == 0
        {
            player!.play()
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
            
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as? TrackCell else { return UITableViewCell() }
        cell.configureStationCell(title: songs.tracks[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSong = indexPath.row
        playOn()
    }
    
    //plays song when song selected from list (slightly different then play button)
    func playOn(){
        songTitle.text = "Loading ..."
        player!.pause()
        player = nil
        setPlayer()
        if player?.rate == 0
        {
            player!.play()
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
        }
    }
}
