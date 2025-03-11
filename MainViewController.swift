import SwiftUI

struct ContentView: View {
    @State private var showWebView = false

    var body: some View {
        VStack {
            Button(action: {
                showWebView = true
            }) {
                Text("Show Web Page")
                    .font(.headline)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .fullScreenCover(isPresented: $showWebView) {
            WebViewScreen(showWebView: $showWebView)
        }
    }
}

#Preview {
    ContentView()
}


import SwiftUI
import WebKit

struct WebViewScreen: View {
    @Binding var showWebView: Bool

    var body: some View {
        NavigationView {
            WebView(url: URL(string: "http://localhost:3000")!, showWebView: $showWebView)
                .navigationBarTitle("Web Page", displayMode: .inline)
                .navigationBarItems(leading: Button("Back") {
                    showWebView = false
                })
        }
    }
}

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var showWebView: Bool

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let jsCheckContent = """
            window.onload = function() {
                let hasContent = document.body.innerText.trim().length > 0 || document.images.length > 0;
                if (!hasContent) {
                    window.webkit.messageHandlers.noContentHandler.postMessage("No content present");
                }
            };
            """
            webView.evaluateJavaScript(jsCheckContent, completionHandler: nil)
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "noContentHandler", let _ = message.body as? String {
                DispatchQueue.main.async {
                    parent.showWebView = false
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()

        // Inject JavaScript and handle messages
        contentController.add(context.coordinator, name: "noContentHandler")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) { }
}


 import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var showWebView: Bool

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let jsCheckContent = """
            window.onload = function() {
                let hasContent = document.body.innerText.trim().length > 0 || document.images.length > 0;
                if (!hasContent) {
                    window.webkit.messageHandlers.noContentHandler.postMessage("No content present");
                }
            };
            """
            
            webView.evaluateJavaScript(jsCheckContent) { [weak self] _, error in
                if let error = error {
                    print("JavaScript execution error: \(error.localizedDescription)")
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "noContentHandler", let _ = message.body as? String {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.showWebView = false
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()

        // Inject JavaScript and handle messages
        contentController.add(context.coordinator, name: "noContentHandler")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) { }
}

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var showWebView: Bool

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let jsCheckContent = """
            (function() {
                let hasContent = document.body.innerText.trim().length > 0 || document.images.length > 0;
                window.webkit.messageHandlers.noContentHandler.postMessage(hasContent);
            })();
            """

            webView.evaluateJavaScript(jsCheckContent) { result, error in
                if let error = error {
                    print("JavaScript execution error: \(error.localizedDescription)")
                    return
                }

                // Ensure result is a valid Boolean
                if let hasContent = result as? Bool, !hasContent {
                    DispatchQueue.main.async {
                        self.parent.showWebView = false
                    }
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "noContentHandler", let hasContent = message.body as? Bool {
                DispatchQueue.main.async {
                    if !hasContent {
                        self.parent.showWebView = false
                    }
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "noContentHandler")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }

        return webView
    }


    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    let jsCheckContent = """
    (function() {
        let hasContent = document.body && document.body.innerText.trim().length > 0;
        let hasImages = document.images.length > 0;
        return hasContent || hasImages;
    })();
    """

    webView.evaluateJavaScript(jsCheckContent) { result, error in
        if let error = error {
            print("JavaScript execution error: \(error.localizedDescription)")
            return
        }

        // Ensure result is a valid Boolean
        if let hasContent = result as? Bool {
            DispatchQueue.main.async {
                if !hasContent {
                    print("No content detected. Closing WebView.")
                    self.parent.showWebView = false
                }
            }
        } else {
            print("Unexpected JavaScript return value:", result ?? "nil")
        }
    }
}

    func updateUIView(_ webView: WKWebView, context: Context) { }
}

