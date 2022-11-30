//
//  RadioPlayer.swift
//  RadioPlayer
//

import UIKit

// Протокол передачи состояния проигрывания плеера, станции и трека
protocol RadioPlayerDelegate: AnyObject {
    func playerStateDidChange(_ playerState: FRadioPlayerState)
    func playbackStateDidChange(_ playbackState: FRadioPlaybackState)
    func trackDidUpdate(_ track: Track?)
}

// Радио-плеер
class RadioPlayer {
    
    weak var delegate: RadioPlayerDelegate?
    
    // Плеер
    let player = FRadioPlayer.shared
    
    // Проигрываемая станция
    var station: RadioStation? {
        didSet { resetTrack(with: station) }
    }
    
    // Проигрываемый трек
    private(set) var track: Track?
    
    init() {
        player.delegate = self
    }
    
    // Проигрывается ли музыка
    func isPlaying() -> Bool { player.isPlaying }
    // Получить состояние
    func getPlayBackState() -> FRadioPlaybackState { player.playbackState }
    // Поставить новую станцию
    func newRadio(with url: URL?) { player.radioURL = url }
    
    func resetRadioPlayer() {
        station = nil
        track = nil
        player.radioURL = nil
    }
    
    // MARK: - Загрузка/Обновление трека
    // Обновите трек, указав имя исполнителя и название трека
    func updateTrackMetadata(artistName: String, trackName: String) {
        if track == nil {
            track = Track(title: trackName, artist: artistName)
        } else {
            track?.title = trackName
            track?.artist = artistName
        }
        
        delegate?.trackDidUpdate(track)
    }
    
    // Сбросить метаданные трека, чтобы использовать текущую информацию о станции
    func resetTrack(with station: RadioStation?) {
        guard let station = station else { track = nil; return }
        updateTrackMetadata(artistName: station.desc, trackName: station.name)
    }
}

// MARK: - FRadioPlayerDelegate
extension RadioPlayer: FRadioPlayerDelegate {
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        delegate?.playerStateDidChange(state)
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        delegate?.playbackStateDidChange(state)
    }
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        guard
            let artistName = artistName, !artistName.isEmpty,
            let trackName = trackName, !trackName.isEmpty else {
                resetTrack(with: station)
                return
        }
        updateTrackMetadata(artistName: artistName, trackName: trackName)
    }
}
