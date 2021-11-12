
import Foundation
import Combine

class ProductDetailService {
    
    private init() {}
    
    static func getOneProduct(id: Int) -> AnyPublisher<Any, Never>? {
        
        // Подготовка параметров для запроса, задаем выбранный id
        let link = Constants.Urls.product + "\(id)"
        
        // Подготовка URL
        guard let urlWithParams = NSURLComponents(string: link), let url = urlWithParams.url else {
            return nil
        }
        
        // Отправляем запрос
        return Networking.shared.getData(url: url)
        
    }
}
