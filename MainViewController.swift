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
