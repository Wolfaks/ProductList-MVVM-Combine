
import UIKit

protocol DetailCellViewModalProtocol: class {
    var title: String { get }
}

class DetailCellViewModel: DetailCellViewModalProtocol {

    var title: String

    init(category: Category) {
        title = category.title
    }

}
