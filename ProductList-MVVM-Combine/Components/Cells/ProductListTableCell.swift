
import UIKit
import Combine

class ProductListTableCell: UITableViewCell {
    
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productProducer: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var stackFooterCell: UIStackView!
    
    var cancellable = Set<AnyCancellable>()

    lazy var cartBtnListView: CartBtnList = {
        let btnList = CartBtnList()
        btnList.translatesAutoresizingMaskIntoConstraints = false
        return btnList
    }()

    lazy var cartCountView: CartCount = {
        let cartCount = CartCount()
        cartCount.translatesAutoresizingMaskIntoConstraints = false
        return cartCount
    }()
    
    var productIndex: Int?

    weak var viewModel: ListCellViewModalProtocol? {
        willSet(viewModel) {

            guard let viewModel = viewModel else { return }

            // Устанавливаем обводку
            setBorder()

            // Заполняем данные
            productCategory.text = viewModel.category
            productTitle.text = viewModel.title
            productProducer.text = viewModel.producer
            productPrice.text = viewModel.price

            // Загрузка изображения, если ссылка пуста, то выводится изображение по умолчанию
            productImage.image = UIImage(named: "nophoto")
            if !viewModel.imageUrl.isEmpty {

                // Загрузка изображения
                guard let imageURL = URL(string: viewModel.imageUrl) else { return }
                ImageNetworking.shared.getImage(link: imageURL) { (img) in
                    DispatchQueue.main.async {
                        self.productImage.image = img
                    }
                }

            }

            // Вывод корзины и кол-ва добавленых в корзину
            cartCountView.countSubject = viewModel.selectedAmount
            setCartButtons(count: viewModel.selectedAmount)

            // bind - Клик на добавление в карзину
            setupBindings()

            // Действия при клике
            setClicable()

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupBindings() {
        
        // bind - Клик на добавление в карзину
        let tapCartBtnGesture = UITapGestureRecognizer(target: self, action: #selector(tapCartAction))
        cartBtnListView.isUserInteractionEnabled = true
        cartBtnListView.addGestureRecognizer(tapCartBtnGesture)
        
        // Изменение количества в корзине
        cartCountView.$countSubject
            .sink { [weak self] count in

                guard let count = count else { return }
                
                // Изменяем значение количества в структуре
                guard let productIndex = self?.productIndex else { return }
                
                // Вывод корзины и кол-ва добавленых в корзину
                self?.setCartButtons(count: count)
                
                // Обновляем значение в корзине в списке через наблюдатель
                NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationUpdateCartCount"), object: nil, userInfo: ["index": productIndex, "count": count, "reload": false])
                
            }.store(in: &cancellable)
        
    }
    
    @objc func tapCartAction() {
        
        // Добавляем товар в карзину
        guard let productIndex = productIndex else { return }
        
        // Вывод корзины и кол-ва добавленых в корзину
        setCartButtons(count: 1)
        
        // Обновляем значение в корзине в списке через наблюдатель
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationUpdateCartCount"), object: nil, userInfo: ["index": productIndex, "count": 1, "reload": false])
        
    }
    
    func setBorder() {
        
        // Устанавливаем обводку
        borderView.layer.cornerRadius = 10.0
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    func setCartButtons(count: Int) {

        // Вывод корзины и кол-ва добавленых в корзину
        if count > 0 {

            // Удаляем cartBtnListView
            stackFooterCell.removeArrangedSubview(cartBtnListView)
            cartBtnListView.removeFromSuperview()
            
            // Выводим переключатель кол-ва продукта в корзине
            stackFooterCell.addArrangedSubview(cartCountView)

            // Задаем текущее значение счетчика
            cartCountView.count = count

            // Constraints
            cartCountView.widthAnchor.constraint(equalToConstant: CartCount.widthSize).isActive = true
            cartCountView.heightAnchor.constraint(equalToConstant: CartCount.heightSize).isActive = true

        } else {

            // Удаляем cartCountView
            stackFooterCell.removeArrangedSubview(cartCountView)
            cartCountView.removeFromSuperview()

            // Выводим кнопку добавления в корзину
            stackFooterCell.addArrangedSubview(cartBtnListView)

            // Constraints
            cartBtnListView.widthAnchor.constraint(equalToConstant: CartBtnList.widthSize).isActive = true
            cartBtnListView.heightAnchor.constraint(equalToConstant: CartBtnList.heightSize).isActive = true

        }
        
    }
    
    @objc func detailTapped() {
        
        // Выполняем переход в детальную информацию
        guard let productIndex = productIndex else { return }

        // Уведомляем наблюдатель о переходе в детальную информацию
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notificationRedirectToDetail"), object: nil, userInfo: ["index": productIndex])
        
    }
    
    func setClicable() {
        
        // Клик на изображение для перехода в детальную информацию
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(detailTapped))
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(tapImageGesture)
        
        // Клик на название для перехода в детальную информацию
        let tapTitleGesture = UITapGestureRecognizer(target: self, action: #selector(detailTapped))
        productTitle.isUserInteractionEnabled = true
        productTitle.addGestureRecognizer(tapTitleGesture)
        
    }
    
}
