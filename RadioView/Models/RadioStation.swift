//
//  RadioStation.swift
//  Heartbeat Radio
//
//  Created by Владимир Рубис on 26.06.2021.
//

import UIKit

struct RadioResponse: Codable {
    var stations: [RadioStation]
}

struct RadioStation: Codable {
    
    var name: String
    var streamURL: String
    var desc: String
    
    init(name: String, streamURL: String, imageURL: String, desc: String, longDesc: String = "") {
        self.name = name
        self.streamURL = streamURL
        self.desc = desc
    }
}

extension RadioStation: Equatable {
    
    static func == (lhs: RadioStation, rhs: RadioStation) -> Bool {
        return (lhs.name == rhs.name) && (lhs.streamURL == rhs.streamURL) && (lhs.desc == rhs.desc)
    }
}

