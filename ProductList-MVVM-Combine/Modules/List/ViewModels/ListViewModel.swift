
import UIKit
import Combine

protocol ListViewModelProtocol: class {
    var input: InputListView { get }
    var output: OutputListView { get }
    func numberOfRows() -> Int
    func visibleCell(index: Int)
    func cellViewModel(product: Product) -> ListCellViewModalProtocol?
}

class ListViewModel: ListViewModelProtocol {

    // Поиск
    private let searchOperationQueue = OperationQueue()
    
    private var lastID: Int = 0
    private var page: Int = 1

    let input: InputListView
    let output: OutputListView
    private var cancellable = Set<AnyCancellable>()

    init() {

        // Bind
        input = InputListView()
        output = OutputListView()

        // setupBindings
        setupBindings()

    }

    private func setupBindings() {
        input.$searchText
                .sink { [weak self] in self?.changeSearchText(with: $0) }
                .store(in: &cancellable)
    }

    private func changeSearchText(with text: String?) {

        // Проверяем измененный в форме текст
        guard text != nil else { return }

        // Очищаем старые данные и обновляем таблицу
        removeAllProducts()

        // Отображаем анимацию загрузки
        output.showLoadIndicator = true

        // Поиск
        let operationSearch = BlockOperation()
        operationSearch.addExecutionBlock { [weak operationSearch] in

            if !(operationSearch?.isCancelled ?? false) {

                // Выполняем поиск

                // Задаем первую страницу
                self.page = 1

                // Запрос данных
                self.loadProducts()

            }

        }
        searchOperationQueue.cancelAllOperations()
        searchOperationQueue.addOperation(operationSearch)

    }

    private func loadProducts() {
        
        lastID = 0

        // Отправляем запрос загрузки товаров
        ProductListService.getProducts(page: page, searchText: input.searchText)?
                .sink { [weak self] data in
                    
                    guard let data = data as? Data else { return }

                    var productListResponse = ProductListResponse()
                    productListResponse.decode(data: data)
                    var products = productListResponse.products

                    // Так как API не позвращает отдельный ключ, который говорит о том, что есть следующая страница, определяем это вручную
                    if !products.isEmpty && products.count == Constants.Settings.maxProductsOnPage {
                                                
                        // Удаляем последний элемент, который используется только для проверки на наличие следующей страницы
                        products.remove(at: products.count - 1)
                        
                        // Получаем id последнего продукта
                        self?.lastID = products.last?.id ?? 0
                        
                    }
                    
                    // Устанавливаем загруженные товары и обновляем таблицу
                    // append contentsOf так как у нас метод грузит как первую страницу, так и последующие
                    self?.appendProducts(products: products)
                    
                    // Обновляем данные в контроллере
                    if self?.page == 1 {
                        self?.output.showLoadIndicator = false
                    }
                    
                    self?.output.reload = true

                }.store(in: &cancellable)

    }

    func numberOfRows() -> Int {
        output.productList.count
    }

    func visibleCell(index: Int) {

        // Проверяем что оторазили последний элемент и если есть, отображаем следующую страницу
        if !output.productList.isEmpty && output.productList.indices.contains(index) && lastID > 0 && lastID == output.productList[index].id {
            
            // Задаем новую страницу
            page += 1

            // Запрос данных
            loadProducts()

        }

    }

    private func removeAllProducts() {
        output.productList.removeAll()
    }

    private func appendProducts(products: [Product]) {
        output.productList.append(contentsOf: products)
    }

    func cellViewModel(product: Product) -> ListCellViewModalProtocol? {
        ListCellViewModel(product: product)
    }
    
}

class InputListView {
    @Published var searchText: String = ""
}

class OutputListView {
    @Published var productList: [Product] = []
    @Published var showLoadIndicator: Bool = true
    @Published var selectProductIndex: Int?
    @Published var reload: Bool?
}
