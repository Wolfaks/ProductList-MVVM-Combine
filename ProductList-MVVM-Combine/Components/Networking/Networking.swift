
import UIKit

class Networking {

    enum LinkList: String {
        case list = "https://rstestapi.redsoftdigital.com/api/v1/products"
        case product = "https://rstestapi.redsoftdigital.com/api/v1/products/"
    }

    // Создаем синглтон для обращения к методам класса
    private init() {
    }
    static let network = Networking()

    public func getData(link: String, params: [String: String], completion: @escaping (Any) -> ()) {

        let session = URLSession.shared

        // Подготовка URL
        guard let urlWithParams = NSURLComponents(string: link) else {
            return
        }

        // Параметры запроса
        var parameters = [URLQueryItem]()
        for (key, value) in params {
            parameters.append(URLQueryItem(name: key, value: value))
        }

        if !parameters.isEmpty {
            urlWithParams.queryItems = parameters
        }
        // END Параметры запроса

        guard let url = urlWithParams.url else {
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        // Выполняем запрос по URL
        session.dataTask(with: urlRequest) { data, response, error in

            guard let data = data else {
                return
            }

            do {

                let json = try JSONSerialization.jsonObject(with: data, options: [])

                DispatchQueue.main.async(execute: {
                    completion(json)
                })

            } catch {
                print(error)
            }

        }.resume()

    }

}
