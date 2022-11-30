//
//  LocaleDataFetcher.swift
//
//  Created by Владимир Рубис on 16.10.2022.
//

import Foundation

// MARK: Протокол получения данных
protocol DataFetcherProtocol {
    
    /// Получает данные из объекта JSON и декодировует их
    ///  - Parameters:
    ///     - from: путь к файлу с данными / url
    ///     - responce: замыкание для захвата данных/ошибки
    func fetchJSONData<T:Decodable>(from: String,
                                    responce: @escaping (T) -> Void)
}

// MARK: Класс для получения и декодировки данных из расположенного локально файла
final class LocalDataFetcher: DataFetcherProtocol {
    
    /// Получает данные из объекта JSON из`file`
    /// Декодирует их в значение типа `T`
    func fetchJSONData<T: Decodable>(from file: String,
                                     responce: @escaping (T) -> Void) {
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else { return }

        guard let data = try? Data(contentsOf: url) else { return }

        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            responce(decodedObject)
        } catch {
            print("Error decode")
        }
    }
}
