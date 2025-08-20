import UIKit
import NetTesterLib

class NetworkCheckCell: UITableViewCell {
    var check: CheckProtocol? {
        didSet {
            guard let check else { return }
            textLabel?.text = check.name ?? "\(type(of: check))"
            detailTextLabel?.text = check.debugInformation
            imageView?.image = check.status.cellImage
            imageView?.tintColor = check.status.cellImageTint
        }
    }
}


extension CheckStatus {
    var cellImage: UIImage {
        switch self {
        case .notLaunchedYet: return UIImage(systemName: "alarm")!
        case .inProgress: return UIImage(systemName: "hourglass")!
        case .success: return UIImage(systemName: "checkmark.circle.fill")!
        case .failed: return UIImage(systemName: "xmark.circle.fill")!
        }
    }
    var cellImageTint: UIColor {
        switch self {
        case .notLaunchedYet: return .systemBrown
        case .inProgress: return .systemYellow
        case .success: return .systemGreen
        case .failed: return .systemRed
        }
    }
}
