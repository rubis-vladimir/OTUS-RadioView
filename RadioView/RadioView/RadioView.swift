//
//  RadioView.swift
//  RadioView
//
//  Created by Владимир Рубис on 30.11.2022.
//

import UIKit

// Вью для наслаждения музыков из радиостанций ;)
public class RadioView: UIView {
    
    //MARK: - Properties
    private let localUrl = "stations.json"
    private let dataFetcher = DataFetcherService()
    private let radioPlayer = RadioPlayer()
    
    private var stations: [RadioStation] = [] {
        didSet {
            stationDidChange()
        }
    }
    
    private var currentStation: RadioStation?
    private var currentTrack: Track?
    
    private lazy var myFullNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rubis Vladimir"
        label.font = UIFont(name: "MarkerFelt-Thin", size: 36)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var songLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "MarkerFelt-Thin", size: 18)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var  artistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "MarkerFelt-Thin", size: 20)
        label.textColor = .black.withAlphaComponent(0.7)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "стоп вкл", in: Bundle(identifier: "org.cocoapods.RadioView"), compatibleWith: .current)
        button.setImage(image, for: .selected)
        let image2 = UIImage(named: "стоп выкл", in: Bundle(identifier: "org.cocoapods.RadioView"), compatibleWith: .current)
        button.setImage(image, for: .selected)
        button.addTarget(self, action: #selector(didPressStopButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var playingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "плэй"), for: .normal)
        button.setImage(UIImage(named: "пауза"), for: .selected)
        button.addTarget(self, action: #selector(didPressPlayingButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "вперед"), for: .normal)
        button.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "назад"), for: .normal)
        button.addTarget(self, action: #selector(didPressPreviousButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        radioPlayer.delegate = self
        setupView()
        fetchStations(with: localUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public func
    public func updateStations(with file: String) {
        fetchStations(with: file)
    }
    
    // MARK: - Private func
    // Настраивает вью
    private func setupView() {
        
        /// Настройка основного вью
        addShadow(shadowColor: .black,
                  shadowOffset: CGSize(width: 4.0,
                                       height: 4.0),
                  shadowRadius: 4,
                  shadowOpacity: 0.4)
        layer.cornerRadius = 20
        backgroundColor = .white
        
        /// Cтэк для кнопок
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        [previousButton, playingButton, stopButton, nextButton].forEach{
            stack.addArrangedSubview($0)
        }
        
        /// Стэк для лейблов
        let stack2 = UIStackView()
        stack2.spacing = 10
        stack2.translatesAutoresizingMaskIntoConstraints = false
        stack2.axis = .vertical
        
        [myFullNameLabel, artistLabel, songLabel].forEach {
            stack2.addArrangedSubview($0)
        }
        
        /// Изображение подложка
        let songImageView: UIImageView = UIImageView(image: UIImage(named: "подложка"))
        
        /// Общий контейнер
        let container = UIStackView()
        container.distribution = .fillProportionally
        container.spacing = 10
        container.axis = .vertical
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addShadow(shadowColor: .black,
                            shadowOffset: CGSize(width: 4, height: 4),
                            shadowRadius: 4,
                            shadowOpacity: 0.3)
        
        [songImageView, stack].forEach{
            container.addArrangedSubview($0)
        }
        
        songImageView.addSubview(stack2)
        addSubview(container)
        
        /// Констрейнты
        NSLayoutConstraint.activate([
            playingButton.heightAnchor.constraint(equalTo: playingButton.widthAnchor),
            stopButton.heightAnchor.constraint(equalTo: playingButton.widthAnchor),
            nextButton.heightAnchor.constraint(equalTo: playingButton.widthAnchor),
            previousButton.heightAnchor.constraint(equalTo: playingButton.widthAnchor),
            
            stack2.topAnchor.constraint(equalTo: songImageView.topAnchor, constant: 20),
            stack2.bottomAnchor.constraint(equalTo: songImageView.bottomAnchor, constant: -30),
            stack2.leadingAnchor.constraint(equalTo: songImageView.leadingAnchor, constant: 20),
            stack2.trailingAnchor.constraint(equalTo: songImageView.trailingAnchor, constant: -20),
            
            container.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    // Подгружает радиостанции
    private func fetchStations(with file: String) {
        dataFetcher.fetchStations(localUrl: file) { [weak self] resp in
            self?.stations = resp.stations
        }
    }
    
    // При изменении набора радиостанций подгружает первую
    private func stationDidChange() {
        let url = URL(string: stations[0].streamURL)
        radioPlayer.newRadio(with: url)
        radioPlayer.station = stations[0]
    }
    
    // Получаем индекс играющей радиостанции
    private func getIndex(of station: RadioStation?) -> Int? {
        guard let station = station, let index = stations.firstIndex(of: station) else { return nil }
        return index
    }
    
    // Нажата кнопка - запустить/приостановить воспроизведение
    @objc private func didPressPlayingButton() {
        radioPlayer.player.togglePlaying()
        stopButton.isSelected = false
    }
    
    // Нажата кнопка - остановить воспроизведение
    @objc private func didPressStopButton(_ sender: Any) {
        radioPlayer.player.stop()
        stopButton.isSelected = true
    }
    
    // Нажата кнопка - включить следующую
    @objc private func didPressNextButton(_ sender: Any) {
        guard let index = getIndex(of: radioPlayer.station) else { return }
        radioPlayer.station = (index + 1 == stations.count) ? stations[0] : stations[index + 1]
        if let station = radioPlayer.station {
            radioPlayer.player.radioURL = URL(string: station.streamURL)
        }
    }
    
    // Нажата кнопка - включить предыдущую
    @objc private func didPressPreviousButton(_ sender: Any) {
        guard let index = getIndex(of: radioPlayer.station) else { return }
        radioPlayer.station = (index == 0) ? stations.last : stations[index - 1]
        if let station = radioPlayer.station {
            radioPlayer.player.radioURL = URL(string: station.streamURL)
        }
    }
    
    // Обновляем лейблы в зависимости от ответа
    private func updateLabels(with statusMessage: String? = nil, animate: Bool = true) {
        guard let statusMessage = statusMessage else {
            songLabel.text = currentTrack?.title
            artistLabel.text = currentTrack?.artist
            return
        }
        
        guard songLabel.text != statusMessage else { return }
        songLabel.text = statusMessage
        artistLabel.text = currentStation?.name
    }
    
    // Обновляет название артиста и песни
    private func updateScreen(with track: Track?) {
        if let artist = track?.artist {
            artistLabel.text = artist
        }
        if let title = track?.title {
            songLabel.text = title
        }
    }
}

// MARK: - RadioPlayerDelegate
extension RadioView: RadioPlayerDelegate {
    func playerStateDidChange(_ state: FRadioPlayerState) {
        let message: String?
        
        switch state {
        case .loading:
            message = "Loading Station ..."
        case .urlNotSet:
            message = "Station URL not valide"
        case .readyToPlay, .loadingFinished:
            playbackStateDidChange(radioPlayer.getPlayBackState())
            return
        case .error:
            message = "Error Playing"
        }
        updateLabels(with: message, animate: true)
    }
    
    func playbackStateDidChange(_ playbackState: FRadioPlaybackState) {
        let message: String?
        
        switch playbackState {
        case .paused:
            message = "Station Paused..."
        case .playing:
            message = nil
        case .stopped:
            message = "Station Stopped..."
        }
        updateLabels(with: message, animate: true)
        playingButton.isSelected = radioPlayer.isPlaying()
    }
    
    func trackDidUpdate(_ track: Track?) {
        updateScreen(with: track)
    }
}
