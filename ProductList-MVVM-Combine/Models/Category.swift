
import UIKit

struct Category: Decodable {
    let id: Int
    let title: String
    let parent_id: Int?
}
