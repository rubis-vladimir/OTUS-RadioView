//
//  RadioView.swift
//  RadioView
//
//  Created by Владимир Рубис on 30.11.2022.
//

import UIKit
import OtusHomework

// Вью для наслаждения музыков из радиостанций ;)
public class RadioView: UIView {
    
    //MARK: - Properties
    private let dataFetcher = DataFetcherService()
    private let radioStationManager = RadioStationManager.shared
    private let radioPlayer = RadioPlayer()
    
    private let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .light, scale: .large)
    private let localUrl = "stations.json"
    
    private lazy var stations: [RadioStation] = [] {
        didSet {
            stationDidChange()
        }
    }
    
    private var currentStation: RadioStation?
    private var currentTrack: Track?
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var myFullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Rubis Vladimir"
        label.font = UIFont(name: "MarkerFelt-Thin", size: 36)
        return label
    }()
    
    private lazy var songLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "MarkerFelt-Thin", size: 18)
        label.textColor = .systemGray
        return label
    }()

    private lazy var  artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MarkerFelt-Thin", size: 20)
        label.textColor = .black.withAlphaComponent(0.7)
        return label
    }()
    
    private lazy var stopButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "stop.fill")?.withConfiguration(config), for: .selected)
        button.setImage(UIImage(systemName: "stop")?.withConfiguration(config), for: .normal)
        button.addTarget(self, action: #selector(didPressStopButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var playingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play")?.withConfiguration(config), for: .normal)
        button.setImage(UIImage(systemName: "pause")?.withConfiguration(config), for: .selected)
        button.addTarget(self, action: #selector(didPressPlayingButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward")?.withConfiguration(config), for: .normal)
        button.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward")?.withConfiguration(config), for: .normal)
        button.addTarget(self, action: #selector(didPressPreviousButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init + LayoutSubviews
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        radioPlayer.delegate = self
        setupView()
        stations = radioStationManager.getStations()
        fetchStations(from: localUrl)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        stack.layoutSubviews()
        [previousButton, playingButton, stopButton, nextButton].forEach {
            $0.layer.cornerRadius = $0.frame.height / 2
        }
    }
    
    // MARK: - Public func
    // Подгрузить новые станции из файла
    public func updateStations(from file: String) {
        fetchStations(from: file)
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
        
        /// Для кнопок
        [previousButton, playingButton, stopButton, nextButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = #colorLiteral(red: 0.9616639018, green: 0.956697166, blue: 0.9524772763, alpha: 1)
            $0.tintColor = .black.withAlphaComponent(0.7)
            $0.addShadow(shadowColor: .black, shadowOffset: CGSize(width: 2, height: 2), shadowRadius: 2, shadowOpacity: 0.3)
            stack.addArrangedSubview($0)
        }
        
        /// Стэк для лейблов
        let stack2 = UIStackView()
        stack2.spacing = 10
        stack2.translatesAutoresizingMaskIntoConstraints = false
        stack2.axis = .vertical
        stack2.addShadow(shadowColor: .black, shadowOffset: CGSize(width: 3, height: 3), shadowRadius: 3, shadowOpacity: 0.3)
        stack2.backgroundColor = #colorLiteral(red: 0.9616639018, green: 0.956697166, blue: 0.9524772763, alpha: 1)
        stack2.layer.cornerRadius = 20
        
        [myFullNameLabel, artistLabel, songLabel].forEach {
            $0.numberOfLines = 0
            $0.textAlignment = .center
            stack2.addArrangedSubview($0)
        }

        /// Общий контейнер
        let container = UIStackView()
        container.distribution = .fillProportionally
        container.spacing = 20
        container.axis = .vertical
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addShadow(shadowColor: .black,
                            shadowOffset: CGSize(width: 4, height: 4),
                            shadowRadius: 4,
                            shadowOpacity: 0.3)
        
        [stack2, stack].forEach{
            container.addArrangedSubview($0)
        }
        
        addSubview(container)
        
        /// Констрейнты
        NSLayoutConstraint.activate([
            stack.heightAnchor.constraint(equalTo: playingButton.widthAnchor),
            songLabel.heightAnchor.constraint(equalToConstant: 25),
            
            container.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
        print(playingButton.frame.width, playingButton.frame.height)
    }
    
    // Подгружает радиостанции
    private func fetchStations(from file: String) {
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

// MARK: - HasOtusHomeworkView
extension RadioView: HasOtusHomeworkView {
    public var squareView: UIView? {
        self
    }
    
    public var squareViewController: UIViewController? {
        nil
    }
}
