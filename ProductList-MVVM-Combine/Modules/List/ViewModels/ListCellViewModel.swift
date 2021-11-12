
import UIKit

protocol ListCellViewModalProtocol: class {
    var category: String { get }
    var title: String { get }
    var producer: String { get }
    var price: String { get }
    var imageUrl: String { get }
    var selectedAmount: Int { get }
}

class ListCellViewModel: ListCellViewModalProtocol {

    var category: String = "Нет категории"
    var title: String
    var producer: String
    var price: String
    var imageUrl: String
    var selectedAmount: Int

    init(product: Product) {

        title = product.title
        producer = product.producer
        imageUrl = product.imageUrl
        selectedAmount = product.selectedAmount

        // Убираем лишние нули после запятой, если они есть и выводим цену
        price = String(format: "%g", product.price) + " ₽"
        
        self.getFirstCategory(categories: product.categories)
    }
    
    private func getFirstCategory(categories: [Category]?) {
        if let categories = categories, !categories.isEmpty, let firstCategory = categories.first {
            self.category = firstCategory.title
        }
    }
}
