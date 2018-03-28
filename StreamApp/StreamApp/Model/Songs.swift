//
//  Songs.swift
//  StreamApp
//
//  Created by Soufiane Salouf on 3/28/18.
//  Copyright © 2018 Soufiane Salouf. All rights reserved.
//

import Foundation

struct Songs: Decodable {
    public private(set) var tracks = [Track]()
}
