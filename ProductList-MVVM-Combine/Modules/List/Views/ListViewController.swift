
import UIKit
import Combine

class ListViewController: UIViewController {

    @IBOutlet weak var searchForm: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!

    // viewModel
    var viewModel: ListViewModelProtocol!
    private var cancellable = Set<AnyCancellable>()
    
    weak var detailViewController: DetailViewControllerProtocol?

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
        
        // Переход в полный вид
        viewModel.output.$selectProductIndex
                .sink(receiveValue: { [weak self] index in
                    guard let index = index else { return }
                    self?.redirectToDetail(index: index)
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
    
    private func bindDetailUpdateCard() {
        // Обновление товара в корзине
        self.detailViewController?.cardCountUpdatePublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] cardCountUpdate in
                    guard let cardCountUpdate = cardCountUpdate else { return }
                    self?.updateCartCount(cardCountUpdate: cardCountUpdate)
                }).store(in: &cancellable)
    }
    
    @IBAction func removeSearch(_ sender: Any) {

        // Очищаем форму поиска
        searchForm.text = ""
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: searchForm)

        // Скрываем клавиатуру
        hideKeyboard()
        
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func redirectToDetail(index: Int) {
        
        // Выполняем переход в детальную информацию
        if !viewModel.output.productList.indices.contains(index) { return }
        
        // Выполняем переход в детальную информацию
        detailViewController = DetailViewController.storyboardInstance()
        if let detailViewController = detailViewController as? UIViewController {
            self.detailViewController?.setProductData(productIndex: index,
                                                productID: viewModel.output.productList[index].id,
                                                productTitle: viewModel.output.productList[index].title,
                                                productSelectedAmount: viewModel.output.productList[index].selectedAmount)
            
            bindDetailUpdateCard()
            
            navigationController?.pushViewController(detailViewController, animated: true)
        }
        
    }
    
    private func updateCartCount(cardCountUpdate: CardCountUpdate) {
        
        if !viewModel.output.productList.indices.contains(cardCountUpdate.index) { return }

        viewModel.output.productList[cardCountUpdate.index].selectedAmount = cardCountUpdate.value
        
        if cardCountUpdate.reload {
            tableView.reloadData()
        }
        
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
        cell.listViewModel = viewModel
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
        
        // Проверяем что оторазили последний элемент и если есть, отображаем следующую страницу
        guard viewModel != nil else { return }
        viewModel.visibleCell(index: indexPath.row)
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
