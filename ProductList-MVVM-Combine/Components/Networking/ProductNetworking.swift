
import Foundation
import Combine

class ProductNetworking {

    // Задаем максимальное количество элементов на странице статической константой, чтобы обращаться из других класов
    static let maxProductsOnPage = 21
    
    private init() {}
    
    static func getProducts(page: Int, searchText: String) -> AnyPublisher<Any, Never> {

        // Подготовка параметров для запроса, задаем макс количество элементов = 21
        var params = ["maxItems": "\(maxProductsOnPage)"]

        // Страница
        var startFrom = 0
        if page > 0 {
            startFrom = ((page - 1) * (maxProductsOnPage - 1));
        }
        params["startFrom"] = "\(startFrom)"

        // Поиск
        if !searchText.isEmpty {
            params["filter[title]"] = searchText
        }

        // Подготовка URL
        let urlWithParams = NSURLComponents(string: Networking.LinkList.list.rawValue)!

        // Параметры запроса
        var parameters = [URLQueryItem]()
        for (key, value) in params {
            parameters.append(URLQueryItem(name: key, value: value))
        }

        if !parameters.isEmpty {
            urlWithParams.queryItems = parameters
        }
        // END Параметры запроса
        let url = urlWithParams.url

        // Отправляем запрос
        return Networking.shared.getData(url: url!)
        
    }
    
    static func getOneProduct(id: Int) -> AnyPublisher<Any, Never> {

        // Подготовка параметров для запроса, задаем выбранный id
        let link = Networking.LinkList.product.rawValue + "\(id)"

        // Подготовка URL
        let urlWithParams = NSURLComponents(string: link)!
        let url = urlWithParams.url

        // Отправляем запрос
        return Networking.shared.getData(url: url!)
        
    }
    
}
