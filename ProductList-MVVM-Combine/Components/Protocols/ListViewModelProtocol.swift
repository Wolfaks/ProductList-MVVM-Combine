
import Foundation

protocol ListViewModelProtocol {
    var showLoadIndicator: () -> () { get set }
    var hideLoadIndicator: () -> () { get set }
    func updateCartCount(index: Int, value: Int)
    func numberOfRows() -> Int
    func visibleCell(Index: Int)
    var input: InputListView { get }
    var output: OutputListView { get }
    func cellViewModel(product: Product) -> ListCellViewModalProtocol?
}
