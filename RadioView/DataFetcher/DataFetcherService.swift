//
//  DataFetcherService.swift
//  #18 TalkingFriends
//
//  Created by Владимир Рубис on 16.10.2022.
//

import Foundation

// MARK: Сервис получения данных
final class DataFetcherService {
    
    var dataFetcher: DataFetcherProtocol
    
    init(dataFetcher: DataFetcherProtocol = LocalDataFetcher()) {
        self.dataFetcher = dataFetcher
    }
    
    /// Возвращает массив радио респонс, декодированный
    /// из локально расположенного файла JSON
    func fetchStations(localUrl: String, completion: @escaping (RadioResponse) -> Void) {
        dataFetcher.fetchJSONData(from: localUrl, responce: completion)
    }
}
