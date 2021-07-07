
import Foundation

protocol ListViewModelProtocol {
    func numberOfRows() -> Int
    func visibleCell(Index: Int)
    var input: InputListView { get }
    var output: OutputListView { get }
    func cellViewModel(product: Product) -> ListCellViewModalProtocol?
}
