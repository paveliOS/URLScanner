import Foundation

protocol URLScannerProtocol: class {
    func scan(url: URL, numberOfThreads: Int?, searchText: String, maxURLsCount: Int, completionHandler: ((Int) -> Void)?)
    func stopScanning()
    func pauseScanning()
    func resumeScanning()
}

extension NSNotification.Name {
    static let urlScanInitiation = NSNotification.Name("urlScanInitiation")
    static let urlScanUpdate = NSNotification.Name("urlScanUpdate")
    
    enum UserInfoKey: String {
        case urls
        case result
        case progress
    }
}

final class URLScanner {
    
    private let queue: OperationQueue
    
    init() {
        queue = OperationQueue()
        queue.qualityOfService = .userInteractive
    }
    
    private func scan(urls: [URL], searchText: String, operationCompletionHandler: ((URLScanOperationResult) -> Void)?) -> [URL] {
        var scannedURLsCount = 0
        var discoveredURLs: [URL] = []
        let semaphore = DispatchSemaphore(value: 0)
        var operations: [URLScanOperation] = []
        for url in urls {
            let operation = URLScanOperation(url: url, searchText: searchText)
            operation.completionBlock = {
                let result = operation.result!
                discoveredURLs.append(contentsOf: result.subURLs)
                scannedURLsCount += 1
                operationCompletionHandler?(result)
                if scannedURLsCount == urls.count {
                    semaphore.signal()
                }
            }
            operations.append(operation)
        }
        queue.addOperations(operations, waitUntilFinished: false)
        semaphore.wait()
        return discoveredURLs
    }
    
    private func broadcastInitiation(urls: [URL]) {
        var userInfo: [AnyHashable : Any] = [:]
        userInfo[NSNotification.Name.UserInfoKey.urls] = urls
        NotificationCenter.default.post(name: .urlScanInitiation, object: nil, userInfo: userInfo)
    }
    
    private func broadcastUpdate(result: URLScanOperationResult, totalScannedURLsCount: Int, maxScannedURLsCount: Int) {
        let percentage = Float(totalScannedURLsCount) / Float(maxScannedURLsCount)
        var userInfo: [AnyHashable : Any] = [:]
        userInfo[NSNotification.Name.UserInfoKey.result] = result
        userInfo[NSNotification.Name.UserInfoKey.progress] = percentage
        NotificationCenter.default.post(name: .urlScanUpdate, object: nil, userInfo: userInfo)
    }
    
}

extension URLScanner: URLScannerProtocol {
    
    func scan(url: URL, numberOfThreads: Int?, searchText: String, maxURLsCount: Int, completionHandler: ((Int) -> Void)?) {
        DispatchQueue.global(qos: .userInteractive).async {
            let queue = self.queue
            if let numberOfThreads = numberOfThreads {
                queue.maxConcurrentOperationCount = numberOfThreads
            }
            
            var urlsToScan: [URL] = [url]
            var totalScannedURLsCount = 0
            
            repeat {
                self.broadcastInitiation(urls: urlsToScan)
                let newURLs = self.scan(urls: urlsToScan, searchText: searchText) { result in
                    totalScannedURLsCount += 1
                    self.broadcastUpdate(result: result, totalScannedURLsCount: totalScannedURLsCount, maxScannedURLsCount: maxURLsCount)
                }
                if totalScannedURLsCount < maxURLsCount {
                    urlsToScan = Array(newURLs.prefix(maxURLsCount - totalScannedURLsCount))
                }
            } while !urlsToScan.isEmpty && totalScannedURLsCount < maxURLsCount
            NSLog("Scanning is complete")
            completionHandler?(totalScannedURLsCount)
        }
    }
    
    func stopScanning() {
        queue.cancelAllOperations()
    }
    
    func pauseScanning() {
        queue.isSuspended = true
    }
    
    func resumeScanning() {
        queue.isSuspended = false
    }
    
}
