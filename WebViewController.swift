import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupBackButton()
        loadWebPage()
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // Inject JavaScript to check for visible content
        let jsCheckContent = """
        window.onload = function() {
            let hasContent = document.body.innerText.trim().length > 0 || document.images.length > 0;
            if (!hasContent) {
                window.webkit.messageHandlers.noContentHandler.postMessage("No content present");
            }
        };
        """
        
        let script = WKUserScript(source: jsCheckContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)
        contentController.add(self, name: "noContentHandler")
        
        config.userContentController = contentController
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func loadWebPage() {
        if let url = URL(string: "http://localhost:3000") {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // Handle JavaScript message for no content detection
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "noContentHandler", let _ = message.body as? String {
            showAlert("No content present")
            // Later replace this alert with Splunk logging
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
