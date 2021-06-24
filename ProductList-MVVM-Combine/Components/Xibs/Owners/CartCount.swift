
import UIKit

protocol CartCountDelegate: class {
    func changeCount(value: Int)
}

@IBDesignable class CartCount: UIView {

    static let widthSize: CGFloat = 92.0
    static let heightSize: CGFloat = 28.0

    @IBOutlet weak var radiusStackView: UIStackView!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var selectedAmount: UILabel!
    
    weak var delegate: CartCountDelegate?
    
    var count: Int = 0 {
        didSet {
            selectedAmount.text = "\(count)"
        }
    }
    
    var view: UIView!
    var nibName: String = "CartCount"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func loadFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
        
    }
    
    func setupView() {
        let view = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        addSubview(view)
        
        // Закругляем углы stackView
        radiusStackView.layer.cornerRadius = 5.0
        
    }
    
    @IBAction func changeCountBtn(_ sender: UIButton) {
        
        // Меняем значение в корзине нажатием на кнопку - / +
        if sender == minusBtn {
            // Нельзя задавать значение меньше нуля
            count = max(0, count - 1)
        } else if sender == plusBtn {
            count += 1
        }
        
        // Изменяем значение количества в структуре
        delegate?.changeCount(value: count)
        
    }
    
}
