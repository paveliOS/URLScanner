import Foundation

final class URLScanOperationResult {
    
    let url: URL
    let matches: [String]
    let subURLs: [URL]
    let error: URLScanError?
    
    init(url: URL, matches: [String], subURLs: [URL], error: URLScanError?) {
        self.url = url
        self.matches = matches
        self.subURLs = subURLs
        self.error = error
    }
    
}
