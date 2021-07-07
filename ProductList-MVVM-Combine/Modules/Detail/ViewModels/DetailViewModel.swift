
import UIKit
import Combine

class DetailViewModel: DetailViewModelProtocol {

    let id: Int

    var title: String = ""
    var producer: String = ""
    var shortDescription: String = ""
    var imageUrl: String = ""
    var image: UIImage
    var price: String = ""
    var selectedAmount: Int = 0

    var cancellable = Set<AnyCancellable>()

    let input: InputDetailView
    let output: OutputDetailView

    init(productID: Int, amount: Int) {

        // Bind
        input = InputDetailView()
        output = OutputDetailView()

        // setup
        id = productID
        selectedAmount = amount
        image = UIImage(named: "nophoto")!

        // Load
        loadProduct()

    }

    func loadProduct() {

        // Отправляем запрос загрузки товара
        ProductNetworking.getOneProduct(id: id)
                .sink { [weak self] data in
                    
                    guard let data = data as? Data else { return }
                    
                    do {

                        // Проверяем что данные были успешно обработаны
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let response = try ProductResponse(product: json)
                        
                        if let product = response.product {

                            self?.title = product.title
                            self?.producer = product.producer
                            self?.shortDescription = product.shortDescription
                            self?.imageUrl = product.imageUrl

                            // Убираем лишние нули после запятой, если они есть и выводим цену
                            self?.price = String(format: "%g", product.price) + " ₽"

                            // categories
                            self?.output.categoryList = product.categories

                            // Загрузка изображения, если ссылка пуста, то выводится изображение по умолчанию
                            if !(self?.imageUrl.isEmpty ?? false) {

                                // Загрузка изображения
                                if let imageURL = URL(string: (self?.imageUrl)!) {

                                    ImageNetworking.networking.getImage(link: imageURL) { (img) in
                                        DispatchQueue.global(qos: .userInitiated).sync {
                                            self?.image = img
                                        }
                                    }

                                }

                            }

                            // Обновляем данные в контроллере
                            self?.output.dataReceived = true

                        }

                    } catch {
                        print(error)
                    }

                }.store(in: &cancellable)

    }

    func numberOfRows() -> Int {
        output.categoryList.count
    }

    func cellViewModel(index: Int) -> DetailCellViewModalProtocol? {
        let category = output.categoryList[index]
        return DetailCellViewModel(category: category)
    }

    func changeCartCount(index: Int, count: Int) {

        // Обновляем значение
        selectedAmount = count

        // Обновляем значение в корзине в списке через наблюдатель
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationUpdateCartCount"), object: nil, userInfo: ["index": index, "count": count, "reload": true])

    }
}

class InputDetailView {}

class OutputDetailView {
    @Published var categoryList: [Category] = []
    @Published var dataReceived: Bool = false
}
