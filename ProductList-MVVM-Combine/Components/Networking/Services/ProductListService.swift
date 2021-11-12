
import Foundation
import Combine

class ProductListService {
    
    private init() {}
    
    static func getProducts(page: Int, searchText: String) -> AnyPublisher<Any, Never>? {
        
        // Подготовка параметров для запроса, задаем макс количество элементов = 21
        var params = ["maxItems": "\(Constants.Settings.maxProductsOnPage)"]
        
        // Страница
        var startFrom = 0
        if page > 0 {
            startFrom = ((page - 1) * (Constants.Settings.maxProductsOnPage - 1));
        }
        params["startFrom"] = "\(startFrom)"
        
        // Поиск
        if !searchText.isEmpty {
            params["filter[title]"] = searchText
        }
        
        // Подготовка URL
        guard let urlWithParams = NSURLComponents(string: Constants.Urls.productsList) else { return nil }
        
        // Параметры запроса
        var parameters = [URLQueryItem]()
        for (key, value) in params {
            parameters.append(URLQueryItem(name: key, value: value))
        }
        
        if !parameters.isEmpty {
            urlWithParams.queryItems = parameters
        }
        // END Параметры запроса
        
        guard let url = urlWithParams.url else { return nil }
        
        // Отправляем запрос
        return Networking.shared.getData(url: url)
        
    }
}
