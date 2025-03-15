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

/// A reusable function to check if a WebView has visible content.
/// This function can be used across different screens.
func checkWebViewContent(_ webView: WKWebView, completion: @escaping (Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {  // Wait for 7 seconds to ensure React loads
        let script = """
            (function() {
                let ignoreClassPatterns = ["header*", "nav-bar*", "top-section*"];  // Class patterns to ignore
                let ignoreIdPatterns = ["main-header*", "top-banner*"];  // ID patterns to ignore

                function matchesPattern(text, patterns) {
                    return patterns.some(pattern => {
                        let regex = new RegExp("^" + pattern.replace("*", ".*") + "$");
                        return regex.test(text);
                    });
                }

                let elements = document.body.getElementsByTagName("*");
                let contentFound = false;

                for (let el of elements) {
                    let classNames = el.className.split(" ");
                    let idName = el.id;

                    // Skip elements matching ignored class or ID patterns
                    if (classNames.some(cls => matchesPattern(cls, ignoreClassPatterns)) ||
                        (idName && matchesPattern(idName, ignoreIdPatterns))) {
                        continue;
                    }

                    // Check if the remaining elements have content
                    let text = el.innerText.trim();
                    let images = el.getElementsByTagName("img").length;

                    if (text.length > 0 || images > 0) {
                        contentFound = true;
                        break;  // Stop checking if content is found
                    }
                }

                return contentFound;
            })()
        """
        webView.evaluateJavaScript(script) { result, error in
            if let hasContent = result as? Bool {
                completion(hasContent)  // Returns true if content exists, false otherwise
            } else {
                completion(false)  // Default to false if there's an error
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



