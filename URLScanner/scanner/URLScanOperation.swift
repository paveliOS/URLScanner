import Foundation

final class URLScanOperation: AsyncOperation {
    
    private let url: URL
    private let searchText: String
    private let parser: URLParserProtocol
    private(set) var result: URLScanOperationResult?
    private var task: URLSessionDataTask?
    
    init(url: URL, searchText: String) {
        self.url = url
        self.searchText = searchText
        self.parser = URLParser()
        super.init()
    }
    
    override func main() {
        NSLog("Scanning operation is started for: \(url.debugDescription)")
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            var matches: [String] = []
            var subURLs: [URL] = []
            var scanError: URLScanError?
            if let _ = error {
                scanError = .load
            } else {
                if let data = data, let string = String(bytes: data, encoding: .utf8) {
                    do {
                        let urlMatches = try self.parser.matches(of: RegularExpression.urlValidation.rawValue, in: string, onlyUnique: true)
                        subURLs = urlMatches.map { URL(string: $0) }.filter { $0 != nil }.filter { $0 != self.url } as! [URL]
                        matches = try self.parser.matches(of: self.searchText, in: string, onlyUnique: false)
                    } catch let error {
                        NSLog("\(self.url.absoluteString) : \(error.localizedDescription)")
                        scanError = .parse
                    }
                } else {
                    NSLog("Failed to parse response for: \(self.url.absoluteString)")
                    scanError = .parse
                }
            }
            NSLog("\(self.url.absoluteString): \(matches.count) matches, \(subURLs.count) subURLs, error: \(String(describing: scanError?.description))")
            self.result = URLScanOperationResult(url: self.url, matches: matches, subURLs: subURLs, error: scanError)
            self.state = .finished
        }
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    
}



