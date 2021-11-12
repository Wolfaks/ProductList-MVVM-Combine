
import UIKit

struct Product: Decodable {
    let id: Int
    let title: String
    let shortDescription: String
    let imageUrl: String
    let amount: Int
    var price: Double
    let producer: String
    
    var selectedAmount = 0
    var categories: [Category]?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case shortDescription = "shortDescription"
        case imageUrl = "imageUrl"
        case amount = "amount"
        case price = "price"
        case producer = "producer"
        case categories = "categories"
    }
}
