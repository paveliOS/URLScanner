import UIKit

protocol ScannerRouterProtocol: class {
    
}

final class ScannerRouter {
    
    private static let storyboardName = "Scanner"
    private static let vcID = "ScannerViewController"
    
}

extension ScannerRouter: ScannerRouterProtocol {
    
}

extension ScannerRouter {
    
    static func setupScannerModule() -> UIViewController {
        let router = ScannerRouter()
        
        let view = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: vcID) as! ScannerViewController
        let presenter = ScannerPresenter(view: view, router: router)
        
        view.presenter = presenter
        return view
    }
    
}
