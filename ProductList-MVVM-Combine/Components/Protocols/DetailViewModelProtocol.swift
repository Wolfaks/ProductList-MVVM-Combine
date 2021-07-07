
import UIKit
import Combine

protocol DetailViewModelProtocol {
    var title: String { get }
    var producer: String { get }
    var price: String { get }
    var shortDescription: String { get }
    var image: UIImage { get }
    func numberOfRows() -> Int
    func changeCartCount(index: Int, count: Int)
    var selectedAmount: Int { get set }
    var output: OutputDetailView { get }
    func cellViewModel(index: Int) -> DetailCellViewModalProtocol?
}
