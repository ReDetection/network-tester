import UIKit
import NetTesterLib

class NetworkCheckCell: UITableViewCell {
    static let defaultReuseIdentifier: String = "BasicCheckCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        detailTextLabel?.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var check: CheckProtocol? {
        didSet {
            guard let check else { return }
            textLabel?.text = check.name ?? "\(type(of: check))"
            imageView?.image = check.status.cellImage
            imageView?.tintColor = check.status.cellImageTint
            detailTextLabel?.text = check.status == .failed ? check.debugInformation : nil
        }
    }
}


extension CheckStatus {
    var cellImage: UIImage {
        switch self {
        case .notLaunchedYet: return UIImage(systemName: "alarm")!
        case .inProgress: return UIImage(systemName: "hourglass")!
        case .success: return UIImage(systemName: "checkmark.circle.fill")!
        case .warning: return UIImage(systemName: "exclamationmark.octagon.fill")!
        case .failed: return UIImage(systemName: "xmark.circle.fill")!
        }
    }
    var cellImageTint: UIColor {
        switch self {
        case .notLaunchedYet: return .systemBrown
        case .inProgress: return .systemYellow
        case .success: return .systemGreen
        case .warning: return .systemYellow
        case .failed: return .systemRed
        }
    }
}
