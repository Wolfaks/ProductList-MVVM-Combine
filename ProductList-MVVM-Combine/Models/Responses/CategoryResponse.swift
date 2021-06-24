
import Foundation

struct CategoryResponse {
    
    var categories = [Category]()

    init(array: Any) {
        
        // Обрабатываем полученные данные
        guard let categoriesDict = array as? [[String: Any]] else { return }

        // Перевод словаря в объекты модели
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: categoriesDict, options: [])
            let decoder = JSONDecoder()
            categories = try decoder.decode([Category].self, from: jsonData)
        } catch {
            //print(error.localizedDescription)
        }
        
    }
    
}
