
import UIKit

class ListCellViewModel: ListCellViewModalProtocol {

    var category: String
    var title: String
    var producer: String
    var price: String
    var imageUrl: String
    var selectedAmount: Int

    init(product: Product) {

        category = product.category
        title = product.title
        producer = product.producer
        imageUrl = product.imageUrl
        selectedAmount = product.selectedAmount

        // Убираем лишние нули после запятой, если они есть и выводим цену
        price = String(format: "%g", product.price) + " ₽"

    }

}
