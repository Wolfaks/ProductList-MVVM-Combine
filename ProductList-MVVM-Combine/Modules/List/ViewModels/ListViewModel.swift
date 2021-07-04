
import UIKit
import Combine

class ListViewModel: ListViewModelProtocol {

    var showLoadIndicator: () -> () = {}
    var hideLoadIndicator: () -> () = {}

    // Поиск
    var searchString = ""
    private let searchOperationQueue = OperationQueue()

    // Страницы
    var page: Int = 1
    var haveNextPage: Bool = false

    let input: InputListView
    let output: OutputListView
    var cancellable = Set<AnyCancellable>()

    init() {

        // Bind
        input = InputListView()
        output = OutputListView()

        // setupBindings
        setupBindings()

        // Load
        loadProducts()

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
        showLoadIndicator()

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

    func loadProducts() {

        // Отправляем запрос загрузки товаров
        ProductNetworking.getProducts(page: page, searchText: input.searchText) { [weak self] (response) in

            // Обрабатываем полученные товары
            var products = response.products

            // Так как API не позвращает отдельный ключ, который говорит о том, что есть следующая страница, определяем это вручную
            if !products.isEmpty && products.count == ProductNetworking.maxProductsOnPage {

                // Задаем наличие следующей страницы
                self?.haveNextPage = true

                // Удаляем последний элемент, который используется только для проверки на наличие следующей страницы
                products.remove(at: products.count - 1)

            }

            // Устанавливаем загруженные товары и обновляем таблицу
            // append contentsOf так как у нас метод грузит как первую страницу, так и последующие
            self?.appendProducts(products: products)

            // Обновляем данные в контроллере
            if self?.page == 1 {
                self?.hideLoadIndicator()
            }

        }

    }

    func numberOfRows() -> Int {
        output.productList.count
    }

    func visibleCell(Index: Int) {

        // Проверяем что оторазили последний элемент и если есть, отображаем следующую страницу
        if !output.productList.isEmpty && (output.productList.count - 1) == Index, haveNextPage {

            // Задаем новую страницу
            haveNextPage = false
            page += 1

            // Запрос данных
            loadProducts()

        }

    }

    func removeAllProducts() {
        output.productList.removeAll()
    }

    func appendProducts(products: [Product]) {
        output.productList.append(contentsOf: products)
    }

    func updateCartCount(index: Int, value: Int) {
        guard !output.productList.isEmpty && output.productList.indices.contains(index) else { return }
        output.productList[index].selectedAmount = value
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
}