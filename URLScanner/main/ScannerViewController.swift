import UIKit

protocol ScannerView: class {
    func updateProgress(viewData: ScanProgressViewData)
    func insertRows(rows: [Int])
    func updateRows(rows: [Int])
    func reloadResults()
    func displayCompletedTaskControls()
}

final class ScannerViewController: UIViewController {
    
    @IBOutlet private var urlField: ValidatableField!
    @IBOutlet private var threadsCountField: ValidatableField!
    @IBOutlet private var searchTextField: ValidatableField!
    @IBOutlet private var urlsCountField: ValidatableField!
    
    @IBOutlet private var scanInputView: UIStackView!
    @IBOutlet private var scannedURLsTableView: UITableView!
    
    @IBOutlet private var startButton: UIButton!
    @IBOutlet private var pauseResumeButton: UIButton!
    @IBOutlet private var stopButton: UIButton!
    @IBOutlet private var okButton: UIButton!
    
    @IBOutlet private var progressStackView: UIStackView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var progressLabel: UILabel!
    
    var presenter: ScannerViewPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initialControlsSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func actionStart(_ sender: UIButton) {
        guard urlField.isValid else {
            urlField.shake()
            return
        }
        guard threadsCountField.isValid else {
            threadsCountField.shake()
            return
        }
        guard searchTextField.isValid else {
            searchTextField.shake()
            return
        }
        guard urlsCountField.isValid else {
            urlsCountField.shake()
            return
        }
        
        ongoingTaskControlsSetup()
        
        let url = urlField.text!
        let numberOfThreads = Int(threadsCountField.text!)
        let searchText = searchTextField.text!
        let maxURLsCount = Int(urlsCountField.text!)!
    
        let viewData = ScanInputViewData(url: url, numberOfThreads: numberOfThreads, searchText: searchText, maxURLsCount: maxURLsCount)
        presenter.onStartAction(viewData: viewData)
    }
    
    @IBAction private func actionStop(_ sender: UIButton) {
        initialControlsSetup()
        presenter.onStopAction()
    }
    
    @IBAction private func actionPauseResume(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            presenter.onPauseAction()
        } else {
            presenter.onResumeAction()
        }
    }
    
    @IBAction private func actionOK(_ sender: UIButton) {
        initialControlsSetup()
        presenter.onOKAction()
    }
    
    private func setup() {
        scannedURLsTableView.tableFooterView = UIView()
        urlField.setRegularExpression(RegularExpression.urlValidation.rawValue)
        threadsCountField.setRegularExpression(RegularExpression.getForNumberValidation(length: 7, optional: true))
        searchTextField.setRegularExpression(RegularExpression.getForLengthValidation(min: 1, max: 64))
        urlsCountField.setRegularExpression(RegularExpression.getForNumberValidation(length: 7, optional: false))
    }
    
    private func initialControlsSetup() {
        scannedURLsTableView.isHidden = true
        progressStackView.isHidden = true
        scanInputView.isHidden = false
        stopButton.isHidden = true
        pauseResumeButton.isHidden = true
        okButton.isHidden = true
        startButton.isHidden = false
        pauseResumeButton.isSelected = false
        progressView.setProgress(0, animated: true)
        progressLabel.text = "0 %"
    }
    
    private func ongoingTaskControlsSetup() {
        scanInputView.isHidden = true
        scannedURLsTableView.isHidden = false
        progressStackView.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = false
        pauseResumeButton.isHidden = false
    }


}

extension ScannerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let urlCell = tableView.dequeueReusableCell(withIdentifier: URLCell.identifier, for: indexPath) as! URLCell
        let viewData = presenter.urls[indexPath.row]
        urlCell.setData(viewData: viewData)
        return urlCell
    }
    
}

extension ScannerViewController: UITableViewDelegate {
    
}

extension ScannerViewController: ScannerView {
    
    func updateProgress(viewData: ScanProgressViewData) {
        progressView.setProgress(viewData.percentage, animated: true)
        progressLabel.text = "\(Int(viewData.percentage * 100)) %"
    }
    
    func insertRows(rows: [Int]) {
        let indexPaths = rows.map { IndexPath(row: $0, section: 0) }
        scannedURLsTableView.beginUpdates()
        scannedURLsTableView.insertRows(at: indexPaths, with: .bottom)
        scannedURLsTableView.endUpdates()
    }
    
    func updateRows(rows: [Int]) {
        let indexPaths = rows.map { IndexPath(row: $0, section: 0) }
        scannedURLsTableView.beginUpdates()
        scannedURLsTableView.reloadRows(at: indexPaths, with: .fade)
        scannedURLsTableView.endUpdates()
    }
    
    func insertResult() {
        scannedURLsTableView.beginUpdates()
        scannedURLsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
        scannedURLsTableView.endUpdates()
    }
    
    func reloadResults() {
        scannedURLsTableView.reloadData()
    }
    
    func displayCompletedTaskControls() {
        pauseResumeButton.isHidden = true
        stopButton.isHidden = true
        okButton.isHidden = false
    }
    
}
