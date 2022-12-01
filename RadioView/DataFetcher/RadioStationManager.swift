//
//  RadioStationManager.swift
//  TestNew
//
//  Created by Владимир Рубис on 01.12.2022.
//

import UIKit

// Класс для получения дефолтных радиостанций
class RadioStationManager {
    
    static let shared = RadioStationManager()
    
    private init() {}
    
    private struct Stations {
        static var names: [String] = [
            "Absolute Country Hits",
            "Electro Swing Radio",
            "Radio Carcija",
            "WRock",
            "The Rock FM"
        ]
        static var streamURLs: [String] = [
            "http://strm112.1.fm/acountry_mobile_mp3",
            "https://electroswing-radio.com/electro_swing_revolution_radio.m3u",
            "http://87.118.126.101:19406/listen.pls?sid=1",
            "http://37.187.79.93:8248/listen.pls?sid=1",
            "http://tunein-icecast.mediaworks.nz/rock_128kbps"
        ]
        static var desc: [String] = [
            "The Music Starts Here",
            "On Air Since 2012",
            "Vašu i Našu Radiocarsiju",
            "The Philipines Original Rock Radio",
            "Rock Music"
        ]
    }
    
    /// Получаем дефолтные станции
    func getStations() -> [RadioStation] {
        var stations = [RadioStation]()
        
        for index in 0..<Stations.streamURLs.count {
            stations.append(
                RadioStation(name: Stations.names[index],
                             streamURL: Stations.streamURLs[index],
                             desc: Stations.desc[index]
                            )
            )
        }
        return stations
    }
}

