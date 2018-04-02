//
//  DataService.swift
//  StreamApp
//
//  Created by Soufiane Salouf on 4/1/18.
//  Copyright © 2018 Soufiane Salouf. All rights reserved.
//

import Foundation
import CoreData

class DataService {
    static let instance = DataService()
    var songs : Songs!
    var playlists = [Playlist]()
    var songsToPlay = [Track]()
    
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
    
    func importPlaylists(completion: (_ complete: Bool) -> () ){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        
        do {
            playlists = try managedContext.fetch(fetchRequest) as! [Playlist]
            print("Fetching data successfully!")
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func importSongsToPlay(byPlaylist playlist: Playlist, completion: (_ complete: Bool) -> ()) {
        for song in songs.tracks {
            for track in playlist.tracks! {
                if song.title == track {
                    songsToPlay.append(song)
                }
            }
        }
        if songsToPlay.count >= 1 {
           completion(true)
        } else {
            completion(false)
        }
    }
}
