
import UIKit
import Combine

protocol DetailViewControllerProtocol: class {
    var cardCountUpdatePublisher: Published<CardCountUpdate?>.Publisher { get }
    func setProductData(productIndex: Int, productID: Int, productTitle: String, productSelectedAmount: Int)
}

class DetailViewController: UIViewController, DetailViewControllerProtocol {
    
    var productIndex: Int?
    var productID: Int?
    var productTitle: String?
    var productSelectedAmount = 0
    
    @Published var cardCountUpdate: CardCountUpdate?
    var cardCountUpdatePublisher: Published<CardCountUpdate?>.Publisher { $cardCountUpdate }
    
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
    var viewModel: DetailViewModelProtocol?
    var cancellable = Set<AnyCancellable>()

    static func storyboardInstance() -> DetailViewController? {
        // Для перехода на эту страницу
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "Detail") as? DetailViewController
    }
    
    func setProductData(productIndex: Int, productID: Int, productTitle: String, productSelectedAmount: Int) {
        self.productIndex = productIndex
        self.productID = productID
        self.productTitle = productTitle
        self.productSelectedAmount = productSelectedAmount
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
            viewModel = DetailViewModel()
            viewModel?.input.selectedAmount = productSelectedAmount
            viewModel?.input.id = id

            // tableView
            tableView.delegate = self
            tableView.dataSource = self

        }
        
    }

    private func setupBindings() {
        bindViewModelToView()
    }

    private func bindViewModelToView() {

        // Получение данных из viewModel
        viewModel?.output.$loaded
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] loaded in

                    if loaded, let product = self?.viewModel?.output.product {

                        // Скрываем анимацию загрузки
                        self?.loadIndicator.stopAnimating()

                        // Задаем обновленный заголовок страницы
                        self?.title = product.title

                        // Выводим информацию
                        self?.titleLabel.text = product.title
                        self?.producerLabel.text = product.producer
                        self?.image.image = self?.viewModel?.output.image

                        // Убираем лишние нули после запятой, если они есть и выводим цену
                        self?.priceLabel.text = String(format: "%g", product.price) + " ₽"
                        
                        // Описание
                        self?.changeDescription(text: product.shortDescription)

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
                self?.viewModel?.changeCartCount(index: productIndex, count: count, reload: true)
                self?.setCartButtons()
                
            }.store(in: &cancellable)
        
        // Обновление товара в корзине
        self.viewModel?.cardCountUpdatePublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] cardCountUpdate in
                    guard let cardCountUpdate = cardCountUpdate else { return }
                    self?.updateCartCount(index: cardCountUpdate.index, value: cardCountUpdate.value, reload: cardCountUpdate.reload)
                }).store(in: &cancellable)

    }
    
    @objc func tapCartAction() {
        
        // Добавляем товар в карзину
        guard let productIndex = productIndex, viewModel != nil else { return }

        let addCartCount = 1
        
        // Обновляем кнопку в отображении
        viewModel?.changeCartCount(index: productIndex, count: addCartCount, reload: true)
        setCartButtons()
        
    }
    
    private func setCartButtons() {

        guard let viewModel = viewModel, let product = viewModel.output.product else { return }

        // Вывод корзины и кол-ва добавленых в корзину
        if product.selectedAmount > 0 {
            
            // Выводим переключатель кол-ва продукта в корзине
            cartBtnDetailView.isHidden = true
            cartCountView.isHidden = false
            
            // Задаем текущее значение счетчика
            cartCountView.count = product.selectedAmount
            
        } else {
            // Выводим кнопку добавления в карзину
            cartBtnDetailView.isHidden = false
            cartCountView.isHidden = true
        }
        
    }
    
    private func changeDescription(text: String) {
        
        // Задаем описание
        if text.isEmpty {
            descriptionLabel.isHidden = true
            descriptionLabel.text = ""
        } else {
            descriptionLabel.isHidden = false
            descriptionLabel.text = text
        }
        
    }
    
    private func updateCartCount(index: Int, value: Int, reload: Bool) {
        // Записываем новое значение
        cardCountUpdate = CardCountUpdate(index: index, value: value, reload: reload)
    }
    
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {

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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryListTableCell, let viewModel = viewModel else { return UITableViewCell() }
        
        let cellViewModel = viewModel.cellViewModel(index: indexPath.row)
        cell.viewModel = cellViewModel
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }

}
