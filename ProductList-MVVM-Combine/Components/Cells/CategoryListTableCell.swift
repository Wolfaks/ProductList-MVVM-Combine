
import UIKit

class CategoryListTableCell: UITableViewCell {
    
    @IBOutlet weak var categoryTitle: UILabel!

    weak var viewModel: DetailCellViewModalProtocol? {
        willSet(viewModel) {

            guard let viewModel = viewModel else { return }

            // Устанавливаем название
            categoryTitle.text = viewModel.title

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
