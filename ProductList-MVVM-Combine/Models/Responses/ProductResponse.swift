
import Foundation

struct ProductResponse {
    
    var products = [Product]()
    var product: Product?

    init(products: Any) {
        
        // Обрабатываем полученные данные списка
        guard let arrayJson = products as? [String: AnyObject], let productsArray = arrayJson["data"] as? [[String: AnyObject]] else { return }
        
        // Перебор всех элементов и запись в модель
        var products = [Product]()
        
        for productDict in productsArray {

            // Добавляем в массив
            guard let product = Product(product: productDict) else {
                continue
            }
            products.append(product)

        }
        
        self.products = products
        // END Перебор всех элементов и запись в модель
        
    }
    
    init(product: Any) {
        
        // Обрабатываем полученные данные детальной информации
        guard let arrayJson = product as? [String: AnyObject], let productDisc = arrayJson["data"] as? [String: AnyObject], let product = Product(product: productDisc) else { return }
        
        // Задаем данные товара
        self.product = product
        
    }
    
}
