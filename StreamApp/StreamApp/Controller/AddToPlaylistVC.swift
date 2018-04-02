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
            DataService.instance.newPlaylist(forName: playlistNameTextField.text!, andDescription: playlistDescriptionTextField.text!, andTracks: [track!.title]
                , withCompletionHandler: { (saved) in
                    if saved {
                        dismiss(animated: true, completion: nil)
                    }
            })
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tracks = playlists[indexPath.row].tracks
        var filterdItemsArray = [String]()
        
        
        func filterContentForSearchText(searchText: String) {
            filterdItemsArray = (tracks?.filter { item in
                return item.lowercased().contains(searchText.lowercased())
                })!
        }
        
        filterContentForSearchText(searchText: track!.title)
        
        if (filterdItemsArray.count >= 1 ) {
            dismiss(animated: true, completion: nil)
        } else {
            tracks?.append(track!.title)
            if DataService.instance.updatePlaylist(playlist: playlists[indexPath.row],tracks: tracks!) {
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
