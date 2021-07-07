
import UIKit
import Combine

class DetailViewController: UIViewController {
    
    var productIndex: Int?
    var productID: Int?
    var productTitle: String?
    var productSelectedAmount = 0
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cartBtnDetailView: CartBtnDetail!
    @IBOutlet weak var cartCountView: CartCount!

    // viewModel
    var viewModel: DetailViewModelProtocol!
    var cancellable = Set<AnyCancellable>()

    static func storyboardInstance() -> DetailViewController? {
        // Для перехода на эту страницу
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "Detail") as? DetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUI()
        setupBindings()
    }
    
    private func settingUI() {

        // Задаем заголовок страницы
        if let productTitle = productTitle {
            title = productTitle
        }
        
        // Запрос данных
        if let id = productID {

            // viewModel
            viewModel = DetailViewModel(productID: id, amount: productSelectedAmount)

            // tableView
            tableView.rowHeight = 32.0
            tableView.delegate = self
            tableView.dataSource = self

        }
        
    }

    private func setupBindings() {
        bindViewModelToView()
    }

    func bindViewModelToView() {

        // Получение данных из viewModel
        viewModel.output.$dataReceived
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] received in

                    if received {

                        // Скрываем анимацию загрузки
                        self?.loadIndicator.stopAnimating()

                        // Задаем обновленный заголовок страницы
                        self?.title = self?.viewModel.title

                        // Выводим информацию
                        self?.titleLabel.text = self?.viewModel.title
                        self?.producerLabel.text = self?.viewModel.producer
                        self?.priceLabel.text = self?.viewModel.price
                        self?.image.image = self?.viewModel.image

                        // Описание
                        self?.changeDescription(text: self?.viewModel.shortDescription ?? "")

                        // Вывод корзины и кол-ва добавленых в корзину
                        self?.setCartButtons()

                        // Отображаем данные
                        self?.infoStackView.isHidden = false

                        // Обновляем данные таблицы категорий
                        self?.tableView.reloadData()

                    }

                }).store(in: &cancellable)
        
        // Клик на добавление в карзину
        let tapCartBtnGesture = UITapGestureRecognizer(target: self, action: #selector(tapCartAction))
        cartBtnDetailView.isUserInteractionEnabled = true
        cartBtnDetailView.addGestureRecognizer(tapCartBtnGesture)
        
        // Изменение количества в корзине
        cartCountView.$countSubject
            .sink { [weak self] count in
              
                guard let count = count else { return }
                
                // Изменяем значение количества в структуре
                guard let productIndex = self?.productIndex, self?.viewModel != nil else { return }
                
                // Обновляем кнопку в отображении
                self?.viewModel.changeCartCount(index: productIndex, count: count)
                self?.setCartButtons()
                
            }.store(in: &cancellable)

    }
    
    @objc func tapCartAction() {
        
        // Добавляем товар в карзину
        guard let productIndex = productIndex, viewModel != nil else { return }

        let addCartCount = 1
        
        // Обновляем кнопку в отображении
        viewModel.changeCartCount(index: productIndex, count: addCartCount)
        setCartButtons()
        
    }
    
    func setCartButtons() {

        guard let viewModel = viewModel else { return }

        // Вывод корзины и кол-ва добавленых в корзину
        if viewModel.selectedAmount > 0 {
            
            // Выводим переключатель кол-ва продукта в корзине
            cartBtnDetailView.isHidden = true
            cartCountView.isHidden = false
            
            // Задаем текущее значение счетчика
            cartCountView.count = viewModel.selectedAmount
            
        } else {
            // Выводим кнопку добавления в карзину
            cartBtnDetailView.isHidden = false
            cartCountView.isHidden = true
        }
        
    }
    
    func changeDescription(text: String) {
        
        // Задаем описание
        if text.isEmpty {
            descriptionLabel.isHidden = true
            descriptionLabel.text = ""
        } else {
            descriptionLabel.isHidden = false
            descriptionLabel.text = text
        }
        
    }
    
}

extension DetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRows() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryListTableCell, let viewModel = viewModel else { return UITableViewCell() }

        let cellViewModel = viewModel.cellViewModel(index: indexPath.row)
        cell.viewModel = cellViewModel

        return cell

    }

}

extension DetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        32.0
    }

}
