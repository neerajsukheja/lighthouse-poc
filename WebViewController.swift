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
                let bodyText = document.body.innerText.trim();
                let images = document.images.length;
                return bodyText.length > 0 || images > 0;
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
