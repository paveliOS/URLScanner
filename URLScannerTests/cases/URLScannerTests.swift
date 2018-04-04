import XCTest
@testable import URLScanner

class URLScannerTests: XCTestCase {
    
    var testURL: URL!
    var numberOfThreads: Int!
    var searchText: String!
    var maxURLsCount: Int!
    
    let scanner: URLScannerProtocol = URLScanner()
    
    override func setUp() {
        super.setUp()
        let bundle = Bundle.init(for: URLScannerTests.self)
        testURL = bundle.url(forResource: "wiki", withExtension: "htm")
        searchText = "foo"
        maxURLsCount = 15
    }
    
    func testScannedURLsCount() {
        let expectation = self.expectation(description: "ScannedURLsCount")
        var count = 0
        scanner.scan(url: testURL, numberOfThreads: nil, searchText: searchText, maxURLsCount: maxURLsCount) { scannedURLsCount in
            count = scannedURLsCount
            expectation.fulfill()
        }
        waitForExpectations(timeout: 30, handler: nil)
        XCTAssert(count <= maxURLsCount)
    }
    
}
