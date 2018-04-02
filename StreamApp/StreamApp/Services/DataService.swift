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
        let managedContext = CoreDataService.managedcontext
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
        songsToPlay = []
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
    
    func newPlaylist(forName name: String,andDescription description: String, andTracks tracks: [String] ,withCompletionHandler completion: (_ finished: Bool) -> () ) {
        let managedContext = CoreDataService.managedcontext
        let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: managedContext)
        let managedObject = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        managedObject.setValue(name, forKey: "playlistName")
        managedObject.setValue(description, forKey: "playlistDescription")
        managedObject.setValue(tracks, forKey: "tracks")
        do {
            try managedContext.save()
            completion(true)
            print("Successfully Saved!")
        } catch {
            debugPrint("Counld not save : \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func deleteElement(playlist: Playlist) -> Bool {
        let context = CoreDataService.managedcontext
        context.delete(playlist)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func updatePlaylist(playlist: Playlist, tracks: [String]) -> Bool {
        let managedContext = CoreDataService.managedcontext
        playlist.setValue(tracks, forKey: "tracks")        
        do {
            try managedContext.save()
            return true
        } catch {
            return false
        }
    }
    
    func deleteAll() -> Bool {
        let context = CoreDataService.managedcontext
        let delete = NSBatchDeleteRequest(fetchRequest: Playlist.fetchRequest())
        do {
            try context.execute(delete)
            return true
        } catch {
            return false
        }
    }
    
    func filterData() -> [Playlist]? {
        let context = CoreDataService.managedcontext
        let fetchRequest:NSFetchRequest<Playlist> = Playlist.fetchRequest()
        var playlist:[Playlist]? = nil
        
        let predicate = NSPredicate(format: "playlistName contains[c] %@", "best")
        fetchRequest.predicate = predicate
        
        do {
            playlist = try context.fetch(fetchRequest)
            return playlist
            
        }catch {
            return playlist
        }
    }
}
