
import UIKit
import Combine

class ListViewController: UIViewController {

    @IBOutlet weak var searchForm: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!

    // viewModel
    var viewModel: ListViewModelProtocol!
    var cancellable = Set<AnyCancellable>()
    
    var productList: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
        setupBindings()
    }
    
    private func settingUI() {

        // Наблюдатель изменения товаров в корзине
        NotificationCenter.default.addObserver(self, selector: #selector(updateCartCount), name: Notification.Name(rawValue: "notificationUpdateCartCount"), object: nil)

        // Наблюдатель перехода в детальную информацию
        NotificationCenter.default.addObserver(self, selector: #selector(showDetail), name: Notification.Name(rawValue: "notificationRedirectToDetail"), object: nil)

        // viewModel
        viewModel = ListViewModel()

        // searchForm
        searchForm.delegate = self

        // tableView
        tableView.rowHeight = 160.0
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    private func setupBindings() {
        bindViewToViewModel()
        bindViewModelToView()
    }

    func bindViewToViewModel() {
        NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: searchForm)
                .compactMap { $0.object as? UITextField }
                .compactMap(\.text)
                .eraseToAnyPublisher()
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .removeDuplicates()
                .assign(to: \.searchText, on: viewModel.input)
                .store(in: &cancellable)
    }

    func bindViewModelToView() {

        // Получение данных из viewModel
        viewModel.output.$productList
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] products in
                    self?.productList = products
                    self?.tableView.reloadData()
                }).store(in: &cancellable)

        // Отображаем или скрываем анимацию загрузки
        viewModel.output.$showLoadIndicator
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] show in

                    if show {
                        // Отображаем анимацию загрузки
                        self?.loadIndicator.startAnimating()
                    } else {
                        // Скрываем анимацию загрузки
                        self?.loadIndicator.stopAnimating()
                    }

                }).store(in: &cancellable)

    }

    @objc func updateCartCount(notification: Notification) {

        // Изменяем кол-во товара в корзине
        guard let userInfo = notification.userInfo, let index = userInfo["index"] as? Int, let newCount = userInfo["count"] as? Int, let reload = userInfo["reload"] as? Bool, let viewModel = viewModel else { return }

        // Записываем новое значение
        productList[index].selectedAmount = newCount
        
        //  Обновление таблицы
        if reload {
            tableView.reloadData()
        }

    }

    @objc func showDetail(notification: Notification) {

        // Переход в детальную информацию
        guard let userInfo = notification.userInfo, let index = userInfo["index"] as? Int, let viewModel = viewModel, !productList.isEmpty && productList.indices.contains(index) else { return }

        // Выполняем переход в детальную информацию
        if let detailViewController = DetailViewController.storyboardInstance() {
            detailViewController.productIndex = index
            detailViewController.productID = productList[index].id
            detailViewController.productTitle = productList[index].title
            detailViewController.productSelectedAmount = productList[index].selectedAmount
            navigationController?.pushViewController(detailViewController, animated: true)
        }

    }
    
    @IBAction func removeSearch(_ sender: Any) {

        // Очищаем форму поиска
        searchForm.text = ""
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: searchForm)

        // Скрываем клавиатуру
        hideKeyboard()
        
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
}

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductListTableCell, let viewModel = viewModel else { return UITableViewCell() }
        let cellViewModel = self.viewModel.cellViewModel(product: productList[indexPath.row])
        cell.productIndex = indexPath.row
        cell.viewModel = cellViewModel

        return cell

    }

}

extension ListViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Проверяем что оторазили последний элемент и если есть, отображаем следующую страницу
        guard viewModel != nil else { return }
        viewModel.visibleCell(Index: indexPath.row)
    }

}

extension ListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == searchForm {
            // Скрываем клавиатуру при нажатии на клавишу Done / Готово
            hideKeyboard()
        }
        
        return true
        
    }
    
}
