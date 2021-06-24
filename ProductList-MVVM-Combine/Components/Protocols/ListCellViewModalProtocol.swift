
import Foundation

protocol ListCellViewModalProtocol: class {
    var category: String { get }
    var title: String { get }
    var producer: String { get }
    var price: String { get }
    var imageUrl: String { get }
    var selectedAmount: Int { get }
}
