//
//  ViewController.swift
//  StreamApp
//
//  Created by Soufiane Salouf on 3/27/18.
//  Copyright © 2018 Soufiane Salouf. All rights reserved.
//

import UIKit
import AVFoundation

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class HomeVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var stopBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var actualDurationLbl: UILabel!
    @IBOutlet weak var fullDurationLbl: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var nowPlayingAnimationImageView: UIImageView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //Variables
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    
    //LIST OF Audio Files
    var playlists = [Playlist]()
    var trackToPlay = [Track]()
    
    
    var currentSong = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        songTitle.text = "Loading ..."
        
        tableView.isHidden = false
        collectionView.isHidden = true
        
        DataService.instance.importSongs()
        trackToPlay = DataService.instance.songs.tracks
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.importPlaylists { (complete) in
            if complete {
                playlists = DataService.instance.playlists
            }
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        
        playbackSlider!.minimumValue = 0
        setPlayer()
        if player?.rate == 0
        {
            player!.play()
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
        }
        // Create NowPlaying Animation
        createNowPlayingAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.importPlaylists { (complete) in
            if complete {
                playlists = DataService.instance.playlists
            }
        }
        collectionView.reloadData()
    }
    
    /* Function called when sliders is adjusted manually.
     */
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        let mySecs2 = Int(seconds) % 60
        let myMins2 = Int(seconds / 60)
        
        let myTimes2 = String(myMins2) + ":" + String(mySecs2)
        actualDurationLbl.text = myTimes2 //current time of audio track
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
            self.startNowPlayingAnimation(true)
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
        }
    }
    
    //setup avplayer avPlayerItem --> objects used to play audio files
    func setPlayer(){
        
        var url: URL!
        if USE_RADIO_URL {
            url = URL(string: RADIO_URL)
        } else {
            url = URL(string: trackToPlay[currentSong].url)
        }
        
        let path = IndexPath(row: currentSong, section: 0)
        tableView.selectRow(at: path, animated: false, scrollPosition: .none)
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        
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
        
        playbackSlider?.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
        //subroutine used to keep track of current location of time in audio file
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime())
                
                //comment out if you don't want continous play
                if(Int(time) == Int(seconds)){
                    self.nextSong()
                }
                
                let mySecs2 = Int(time) % 60
                
                if(mySecs2 == 1){ //show title of song after 1 second
                    self.songTitle.text = self.trackToPlay[self.currentSong].title
                    self.startNowPlayingAnimation(true)
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
        startNowPlayingAnimation(false)
        songTitle.text = "Loading ..."
        if currentSong < trackToPlay.count - 1{
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
        startNowPlayingAnimation(false)
        songTitle.text = "Loading ..."
        if(currentSong > 0){
            currentSong = currentSong - 1
        } else {
            currentSong = trackToPlay.count - 1
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
        songTitle.text = trackToPlay[currentSong].title
        if player?.rate == 0
        {
            player!.play()
            playPauseBtn!.setImage(UIImage(named: "btn-pause.png"), for: UIControlState.normal)
            startNowPlayingAnimation(true)
        } else {
            player!.pause()
            startNowPlayingAnimation(false)
            playPauseBtn!.setImage(UIImage(named: "btn-play.png"), for: UIControlState.normal)
        }
    }
    
    @IBAction func stopBtnWasPressed(_ sender: Any) {
        nowPlayingAnimationImageView.stopAnimating()
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
        startNowPlayingAnimation(false)
        songTitle.text = "Loading ..."
        if(currentSong < trackToPlay.count - 1){
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
    
    func createNowPlayingAnimation() {
        nowPlayingAnimationImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingAnimationImageView.animationDuration = 0.7
    }
    
    func startNowPlayingAnimation(_ animate: Bool) {
        animate ? nowPlayingAnimationImageView.startAnimating() : nowPlayingAnimationImageView.stopAnimating()
    }
    
    @objc func buttonTapped(_ sender:UIButton!){
        performSegue(withIdentifier: "AddToPlaylistVC", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addToPlaylistVC = segue.destination as? AddToPlaylistVC {
            addToPlaylistVC.modalPresentationStyle = .custom
            if let button = sender as? UIButton {
                addToPlaylistVC.track = trackToPlay[button.tag]
            }
        }
    }
    
    @IBAction func songsBtnPressed(_ sender: Any) {
        trackToPlay = DataService.instance.songs.tracks
        tableView.reloadData()
        tableView.isHidden = false
        collectionView.isHidden = true
    }
    
    @IBAction func playlistsBtnPressed(_ sender: Any) {
        DataService.instance.importPlaylists { (complete) in
            if complete {
                playlists = DataService.instance.playlists
            }
        }
        collectionView.reloadData()
        tableView.isHidden = true
        collectionView.isHidden = false
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
        return trackToPlay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as? TrackCell else { return UITableViewCell() }
        cell.configureCell(title: trackToPlay[indexPath.row].title)
        cell.addToPlaylistBtn.tag = indexPath.row //or value whatever you want (must be Int)
        cell.addToPlaylistBtn.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSong = indexPath.row
        playOn()
    }
    
    //plays song when song selected from list (slightly different then play button)
    func playOn(){
        startNowPlayingAnimation(false)
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

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCVCell", for: indexPath) as? PlaylistCVCell else { return UICollectionViewCell() }
        cell.configureCell(playlist: playlists[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var numOfColumns : CGFloat = 3
        if UIScreen.main.bounds.width > 320 {
            numOfColumns = 4
        }
        
        let spaceBetweenCells : CGFloat = 10
        let padding : CGFloat = 40
        let cellDimension = ((collectionView.bounds.width - padding) - (numOfColumns - 1) * spaceBetweenCells) / numOfColumns
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("playlist name: \(playlists[indexPath.row].playlistName!)")
        print("number of songs in the play list : \(playlists[indexPath.row].tracks?.count)")
//        DataService.instance.importSongsToPlay(byPlaylist: playlists[indexPath.row], completion: { (complete) in
//            if complete {
//                trackToPlay = DataService.instance.songsToPlay
//                tableView.reloadData()
//                tableView.isHidden = false
//                collectionView.isHidden = true
//            }
//        })
    }
}
