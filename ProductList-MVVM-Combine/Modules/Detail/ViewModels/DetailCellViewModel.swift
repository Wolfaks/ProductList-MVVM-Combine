
import UIKit

class DetailCellViewModel: DetailCellViewModalProtocol {

    var title: String

    init(category: Category) {
        title = category.title
    }

}
