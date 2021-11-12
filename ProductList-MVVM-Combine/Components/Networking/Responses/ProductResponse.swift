
import Foundation

struct ProductResponse: Decodable, ApiResponse {
    var product: Product?
    
    enum CodingKeys: String, CodingKey {
        case product = "data"
    }
    
    mutating func decode(data: Data) {
        
        // Обрабатываем полученные данные
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let responseDecode = try decoder.decode(ProductResponse.self, from: data)
            self.product = responseDecode.product
        } catch {
            //print(error)
        }
        
    }
}
