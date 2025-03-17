import SwiftUI
import WebKit

/// The main entry point of the app, displaying a button to open the WebView.
struct ContentView: View {
    @State private var showWebView = false  // Controls WebView visibility
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Open WebView") {
                    showWebView = true
                }
                .padding()
                .navigationTitle("Home")
                .fullScreenCover(isPresented: $showWebView) {
                    WebViewScreen(showWebView: $showWebView)
                }
            }
        }
    }
}

/// A screen that contains the WebView inside a NavigationView.
struct WebViewScreen: View {
    @Binding var showWebView: Bool
    @State private var showAlert = false  // Controls alert visibility

    var body: some View {
        NavigationView {
            WebView(urlString: "http://localhost:3000", showAlert: $showAlert)
                .navigationTitle("WebView")
                .navigationBarItems(leading: Button("Back") { showWebView = false })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("No Content Available"), dismissButton: .default(Text("OK")))
                }
        }
    }
}

/// A reusable WebView component that checks for content.
struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var showAlert: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Coordinator to handle WebView navigation events.
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        /// Called when a page load fails.
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if let nsError = error as NSError?, nsError.code == NSURLErrorCannotConnectToHost {
                DispatchQueue.main.async {
                    parent.showAlert = true  // No content due to connection failure
                }
            }
        }

        /// Called when the webpage has finished loading.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            checkWebViewContent(webView) { hasContent in
                DispatchQueue.main.async {
                    parent.showAlert = !hasContent
                }
            }
        }
    }
}

func checkWebViewContent(_ webView: WKWebView, completion: @escaping (Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {  // Wait for 2 seconds to ensure React loads
        let script = """
            (function() {
                let ignoredClasses = ['header', 'head', 'logo'];

                function isVisible(element) {
                    if (!element) return false;
                    let style = window.getComputedStyle(element);
                    return !(style.display === 'none' || style.visibility === 'hidden' || style.opacity === '0');
                }

                function hasValidContent(element) {
                    if (!element || (element.tagName && (element.tagName.toLowerCase() === "noscript" || element.tagName.toLowerCase() === "script"))) {
                        return false;
                    }

                    var classNames = element.className ? element.className.split(" ") : [];
                    if (classNames.some(cls => ignoredClasses.some(ignored => cls.includes(ignored)))) {
                        return false;
                    }

                    if (!isVisible(element)) {
                        return false;
                    }

                    if (element.nodeType === 3) { // Node.TEXT_NODE (3)
                        var text = element.nodeValue.trim();
                        if (text.length > 0) {
                            return true;
                        }
                    }

                    for (var i = 0; i < element.childNodes.length; i++) {
                        if (hasValidContent(element.childNodes[i])) {
                            return true;
                        }
                    }

                    return false;
                }

                return hasValidContent(document.body);
            })()
        """;

        webView.evaluateJavaScript(script) { result, error in
            if let hasContent = result as? Bool {
                completion(hasContent);  // Returns true if visible content exists, false otherwise
            } else {
                completion(false);  // Default to false if there's an error
            }
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
