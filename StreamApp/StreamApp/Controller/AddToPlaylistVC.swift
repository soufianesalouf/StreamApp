//
//  AddToPlaylistVC.swift
//  StreamApp
//
//  Created by Soufiane Salouf on 4/1/18.
//  Copyright © 2018 Soufiane Salouf. All rights reserved.
//

import UIKit
import CoreData

class AddToPlaylistVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var playlistNameTextField: UITextField!
    @IBOutlet weak var playlistDescriptionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noPlaylistLbl: UILabel!
    
    //Variables
    var track : Track!
    var playlists = [Playlist]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
    }
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.instance.importPlaylists { (complete) in
            if complete {
                playlists = DataService.instance.playlists
                if playlists.count >= 1 {
                    tableView.isHidden = false
                    noPlaylistLbl.isHidden = true
                } else {
                    tableView.isHidden = true
                    noPlaylistLbl.isHidden = false
                }
            }
        }
        
        // Round corners
        popupView.layer.cornerRadius = 10
        
        // Set background color to clear
        view.backgroundColor = UIColor.clear
        
        // Add gesture recognizer to dismiss view when touched
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(gestureRecognizer)
    }
    
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************

    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newBtnWasPressed(_ sender: Any) {
        if playlistNameTextField.text != "" {
            self.save { (saved) in
                if saved {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func save(completion: (_ finished: Bool) -> () ) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let playlist = Playlist(context: managedContext)
        playlist.playlistName = playlistNameTextField.text
        playlist.playlistDescription = playlistDescriptionTextField.text
        print(track.title)
        playlist.tracks?.append(track.title)
        print("number Of track: \((playlist.tracks?.count)!)")
        print("the track added : \(playlist.tracks![(playlist.tracks?.count)! - 1])")
        do {
            try managedContext.save()
            completion(true)
            print("Successfully Saved!")
        } catch {
            debugPrint("Counld not save : \(error.localizedDescription)")
            completion(false)
        }
    }
}

extension AddToPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as? PlaylistCell else { return UITableViewCell() }
        cell.configureCell(playlist: playlists[indexPath.row])
        return cell
    }
}
