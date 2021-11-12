
import Foundation

struct ProductListResponse: Decodable, ApiResponse {
    var products = [Product]()
    
    enum CodingKeys: String, CodingKey {
        case products = "data"
    }
    
    mutating func decode(data: Data) {
        
        // Обрабатываем полученные данные
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let responseDecode = try decoder.decode(ProductListResponse.self, from: data)
            self.products = responseDecode.products
        } catch {
            //print(error)
        }
        
    }
}
