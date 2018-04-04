import Foundation

protocol ScannerViewPresenter: class {
    var urls: [URLViewData] { get }
    func onStartAction(viewData: ScanInputViewData)
    func onPauseAction()
    func onResumeAction()
    func onStopAction()
    func onOKAction()
}

final class ScannerPresenter {
    
    private weak var view: ScannerView?
    private let router: ScannerRouterProtocol
    private var urlList: [URLViewData]
    private let scanner: URLScannerProtocol
    
    init(view: ScannerView, router: ScannerRouterProtocol) {
        self.view = view
        self.router = router
        urlList = []
        scanner = URLScanner()
    }
    
    @objc private func onScanInitiation(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let urls = userInfo[NSNotification.Name.UserInfoKey.urls] as! [URL]
        let urlViewData = urls.map {
            URLViewData(url: $0.absoluteString, status: .processing("Processing..."))
        }.reversed()
        
        let rowsToInsert = Array(0..<urlViewData.count)
        
        DispatchQueue.main.async {
            self.urlList.insert(contentsOf: urlViewData, at: 0)
            self.view?.insertRows(rows: rowsToInsert)
        }
    }
    
    @objc private func onScanUpdate(_ notification: NSNotification) {
        let userInfo = notification.userInfo!
        let progress = userInfo[NSNotification.Name.UserInfoKey.progress] as! Float
        let result = userInfo[NSNotification.Name.UserInfoKey.result] as! URLScanOperationResult
        
        DispatchQueue.main.async {
            if let viewDataToUpdate = self.urlList.filter({ $0.url == result.url.absoluteString }).first, let index = self.urlList.index(where: { $0 === viewDataToUpdate} ) {
                let status: URLStatus
                if let error = result.error {
                    status = .error(error.description)
                } else {
                    let description = "\(result.matches.count) matches"
                    if result.matches.isEmpty {
                        status = .failure(description)
                    } else {
                        status = .success(description)
                    }
                }
                
                viewDataToUpdate.status = status
                
                self.view?.updateRows(rows: [index])
                let progressViewData = ScanProgressViewData(percentage: progress)
                self.view?.updateProgress(viewData: progressViewData)
            }
        }
    }

    private func clearList() {
        urlList = []
        view?.reloadResults()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ScannerPresenter: ScannerViewPresenter {
    
    var urls: [URLViewData] {
        return urlList
    }
    
    func onStartAction(viewData: ScanInputViewData) {
        guard let url = URL(string: viewData.url) else {
            NSLog("Failed to initialize URL from string")
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onScanInitiation(_:)), name: .urlScanInitiation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onScanUpdate(_:)), name: .urlScanUpdate, object: nil)
        scanner.scan(url: url, numberOfThreads: viewData.numberOfThreads, searchText: viewData.searchText, maxURLsCount: viewData.maxURLsCount) { _ in
            DispatchQueue.main.async {
                let progressViewData = ScanProgressViewData(percentage: 1)
                self.view?.updateProgress(viewData: progressViewData)
                self.view?.displayCompletedTaskControls()
            }
        }
    }
    
    func onPauseAction() {
        scanner.pauseScanning()
    }
    
    func onResumeAction() {
        scanner.resumeScanning()
    }
    
    func onStopAction() {
        NotificationCenter.default.removeObserver(self, name: .urlScanInitiation, object: nil)
        NotificationCenter.default.removeObserver(self, name: .urlScanUpdate, object: nil)
        clearList()
        scanner.stopScanning()
    }
    
    func onOKAction() {
        NotificationCenter.default.removeObserver(self, name: .urlScanInitiation, object: nil)
        NotificationCenter.default.removeObserver(self, name: .urlScanUpdate, object: nil)
        clearList()
    }
    
}
