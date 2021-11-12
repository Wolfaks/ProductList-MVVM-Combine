
import UIKit
import Combine

protocol ListViewModelProtocol {
    func numberOfRows() -> Int
    func visibleCell(Index: Int)
    var input: InputListView { get }
    var output: OutputListView { get }
    func cellViewModel(product: Product) -> ListCellViewModalProtocol?
}

class ListViewModel: ListViewModelProtocol {

    // Поиск
    private let searchOperationQueue = OperationQueue()

    let input: InputListView
    let output: OutputListView
    var cancellable = Set<AnyCancellable>()

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
        guard let searchString = text else { return }

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
                self.input.page = 1

                // Запрос данных
                self.loadProducts()

            }

        }
        searchOperationQueue.cancelAllOperations()
        searchOperationQueue.addOperation(operationSearch)

    }

    private func loadProducts() {

        // Отправляем запрос загрузки товаров
        ProductListService.getProducts(page: input.page, searchText: input.searchText)?
                .sink { [weak self] data in
                    
                    guard let data = data as? Data else { return }

                    var productListResponse = ProductListResponse()
                    productListResponse.decode(data: data)
                    var products = productListResponse.products

                    // Так как API не позвращает отдельный ключ, который говорит о том, что есть следующая страница, определяем это вручную
                    if !products.isEmpty && products.count == Constants.Settings.maxProductsOnPage {
                        
                        // Задаем наличие следующей страницы
                        self?.input.haveNextPage = true
                        
                        // Удаляем последний элемент, который используется только для проверки на наличие следующей страницы
                        products.remove(at: products.count - 1)
                        
                    }
                    
                    // Устанавливаем загруженные товары и обновляем таблицу
                    // append contentsOf так как у нас метод грузит как первую страницу, так и последующие
                    self?.appendProducts(products: products)
                    
                    // Обновляем данные в контроллере
                    if self?.input.page == 1 {
                        self?.output.showLoadIndicator = false
                    }
                    
                    self?.output.reload = true

                }.store(in: &cancellable)

    }

    func numberOfRows() -> Int {
        output.productList.count
    }

    func visibleCell(Index: Int) {

        // Проверяем что оторазили последний элемент и если есть, отображаем следующую страницу
        if !output.productList.isEmpty && (output.productList.count - 1) == Index, input.haveNextPage {

            // Задаем новую страницу
            input.haveNextPage = false
            input.page += 1

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
    var page: Int = 1
    var haveNextPage: Bool = false
}

class OutputListView {
    @Published var productList: [Product] = []
    @Published var showLoadIndicator: Bool = true
    @Published var reload: Bool?
}
