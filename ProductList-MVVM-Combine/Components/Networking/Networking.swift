
import UIKit
import Combine

class Networking {

    // Создаем синглтон для обращения к методам класса
    private init() {}
    static let shared = Networking()

    public func getData(url: URL) -> AnyPublisher<Any, Never> {

        let session = URLSession.shared

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        // Выполняем запрос по URL
        return session.dataTaskPublisher(for: urlRequest)
                .map { $0.data }
                .replaceError(with: false)
                .eraseToAnyPublisher()

    }

}
