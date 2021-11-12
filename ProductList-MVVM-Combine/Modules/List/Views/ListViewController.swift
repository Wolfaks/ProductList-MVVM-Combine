
import UIKit
import Combine

class ListViewController: UIViewController {

    @IBOutlet weak var searchForm: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!

    // viewModel
    var viewModel: ListViewModelProtocol!
    var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
        setupBindings()
    }
    
    private func settingUI() {

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

    private func bindViewToViewModel() {
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

    private func bindViewModelToView() {

        // Получение данных из viewModel
        viewModel.output.$reload
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] reload in
                    guard let reload = reload, reload else { return }
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
    
    @IBAction func removeSearch(_ sender: Any) {

        // Очищаем форму поиска
        searchForm.text = ""
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: searchForm)

        // Скрываем клавиатуру
        hideKeyboard()
        
    }
    
    private func updateCartCount(index: Int, value: Int, reload: Bool) {
        if !viewModel.output.productList.indices.contains(index) {
            return
        }

        viewModel.output.productList[index].selectedAmount = value
        
        if reload {
            tableView.reloadData()
        }
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductListTableCell, let viewModel = viewModel else { return UITableViewCell() }
        let cellViewModel = self.viewModel.cellViewModel(product: viewModel.output.productList[indexPath.row])
        cell.productIndex = indexPath.row
        cell.viewModel = cellViewModel
        cell.delegate = self
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
        
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

extension ListViewController: ProductListCellDelegate, DetailViewtDelegate {
    
    func changeCartCount(index: Int, value: Int, reload: Bool) {
        
        // Изменяем кол-во товара в корзине
        if !viewModel.output.productList.indices.contains(index) {
            return
        }

        // Записываем новое значение
        updateCartCount(index: index, value: value, reload: reload)
        
    }
    
    func redirectToDetail(index: Int) {
        
        // Выполняем переход в детальную информацию
        if !viewModel.output.productList.indices.contains(index) {
            return
        }
        
        // Выполняем переход в детальную информацию
        if let detailViewController = DetailViewController.storyboardInstance() {

            detailViewController.setProductData(productIndex: index,
                                                productID: viewModel.output.productList[index].id,
                                                productTitle: viewModel.output.productList[index].title,
                                                productSelectedAmount: viewModel.output.productList[index].selectedAmount)
            
            detailViewController.delegate = self
            navigationController?.pushViewController(detailViewController, animated: true)
        }
        
    }
    
}
