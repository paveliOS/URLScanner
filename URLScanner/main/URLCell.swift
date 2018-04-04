import UIKit

final class URLCell: UITableViewCell {
    
    @IBOutlet private var urlLabel: UILabel!
    @IBOutlet private var urlStatusLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

}

extension URLCell {
    
    static let identifier = "URL"
    
    func setData(viewData: URLViewData) {
        urlLabel.text = viewData.url
        var shouldDisplayActivitIndicator = false
        switch viewData.status {
        case .processing(let description):
            urlStatusLabel.text = description
            urlStatusLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.35)
            shouldDisplayActivitIndicator = true
        case .success(let description):
            urlStatusLabel.text = description
            urlStatusLabel.textColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
        case .failure(let description):
            urlStatusLabel.text = description
            urlStatusLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1)
        case .error(let description):
            urlStatusLabel.text = description
            urlStatusLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        if shouldDisplayActivitIndicator {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
}
