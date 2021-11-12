
import UIKit

class ImageNetworking {
    
    // Создаем синглтон для обращения к методам класса
    private init() {}
    
    static let shared = ImageNetworking()
    
    // Кеш изображений
    var cacheImage = NSCache<NSString, UIImage>()
    
    func getImage(link: URL, complition: @escaping (_ image: UIImage) -> ()) {
        
        // Загрузка из кеша если есть
        if let imageCached = cacheImage.object(forKey: link.absoluteString as NSString) {
            complition(imageCached)
        }

        // Выполняем загрузку изображения
        URLSession.shared.dataTask(with: link, completionHandler: { (data, response, error) -> Void in

            // Проверяем что изображение загружено без ошибок
            guard error == nil, data != nil, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }

            // Устанавливаем загруженное изображение // можем использовать force извлечение потому что выше проверили что data != nil
            if let img = UIImage(data: data!) {
                
                // Сохраняем в кеш
                self.cacheImage.setObject(img, forKey: link.absoluteString as NSString)
                complition(img)
                
            }

        }).resume()

    }
    
}
