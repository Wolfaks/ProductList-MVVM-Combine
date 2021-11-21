
import UIKit
import Combine

protocol DetailViewModelProtocol {
    var input: InputDetailView { get }
    var output: OutputDetailView { get }
    func numberOfRows() -> Int
    func changeCartCount(cardCountUpdate: CardCountUpdate)
    func cellViewModel(index: Int) -> DetailCellViewModalProtocol?
}

class DetailViewModel: DetailViewModelProtocol {

    private var cancellable = Set<AnyCancellable>()

    let input: InputDetailView
    let output: OutputDetailView

    init() {

        // Bind
        input = InputDetailView()
        output = OutputDetailView()
        setupBindings()
        
    }
    
    private func setupBindings() {
        input.$id
            .sink(receiveValue: { [weak self] id in
                guard let id = id else { return }
                self?.loadProduct(id: id)
            }).store(in: &cancellable)
    }

    private func loadProduct(id: Int) {
        output.image = UIImage(named: "nophoto")!

        // Отправляем запрос загрузки товара
        ProductDetailService.getOneProduct(id: id)?
                .sink { [weak self] data in
                    
                    guard let data = data as? Data else { return }
                    
                    var productResponse = ProductResponse()
                    productResponse.decode(data: data)
                    
                    if let product = productResponse.product {
                        
                        // Загрузка изображения, если ссылка пуста, то выводится изображение по умолчанию
                        if !(product.imageUrl.isEmpty) {
                            
                            // Загрузка изображения
                            if let imageURL = URL(string: (product.imageUrl)) {
                                
                                ImageNetworking.shared.getImage(link: imageURL) { img in
                                    DispatchQueue.global(qos: .userInitiated).sync {
                                        self?.output.image = img
                                    }
                                }
                                
                            }
                            
                        }

                        // Обновляем данные в контроллере
                        self?.output.product = product
                        self?.output.product?.selectedAmount = self?.input.selectedAmount ?? 0
                        self?.output.loaded = true
                        
                    }

                }.store(in: &cancellable)

    }

    func numberOfRows() -> Int {
        output.product?.categories?.count ?? 0
    }

    func cellViewModel(index: Int) -> DetailCellViewModalProtocol? {
        guard let category = output.product?.categories?[index] else { return nil }
        return DetailCellViewModel(category: category)
    }

    func changeCartCount(cardCountUpdate: CardCountUpdate) {
        // Обновляем значение
        output.product?.selectedAmount = cardCountUpdate.value
        output.cardCountUpdate = CardCountUpdate(index: cardCountUpdate.index, value: cardCountUpdate.value, reload: cardCountUpdate.reload)
    }
}

class InputDetailView {
    var selectedAmount: Int?
    @Published var id: Int?
}

class OutputDetailView {
    @Published var product: Product?
    var image: UIImage?
    @Published var loaded: Bool = false
    
    @Published var cardCountUpdate: CardCountUpdate?
    var cardCountUpdatePublisher: Published<CardCountUpdate?>.Publisher { $cardCountUpdate }
}
