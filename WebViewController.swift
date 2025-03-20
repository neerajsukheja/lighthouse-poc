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
                    Alert(
                        title: Text("No Content Available"),
                        dismissButton: .default(Text("OK")) {
                            showWebView = true  // Reopen WebView when OK is clicked
                        }
                    )
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
            checkWebViewContent(webView) { result in
                DispatchQueue.main.async {
                    parent.showAlert = !(result["result"] as? Bool ?? false)
                }
            }
        }
    }
}

/// A reusable function to check if a WebView has visible content.
/// This function can be used across different screens.
func checkWebViewContent(_ webView: WKWebView, completion: @escaping ([String: Any]) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {  // Wait to ensure React loads
        let script = """
        document.addEventListener("DOMContentLoaded", function () {
            function checkPageContent(classArray = [], idArray = []) {
                try {
                    const contentSelectors = "img, video, canvas, form, iframe, embed, object, audio, picture, svg, map, source, track, blockquote, cite, button, label, select, textarea, table, th, td, ul, ol, li";
                    const errorMessages = [
                        "Webpage not available",
                        "net::ERR_CONNECTION_REFUSED",
                        "This site can't be reached"
                    ];
                    
                    if (errorMessages.some(msg => document.body.innerText.includes(msg))) {
                        return { result: false };
                    }
                    
                    if (classArray.length > 0) {
                        for (let className of classArray) {
                            let elements = document.getElementsByClassName(className);
                            for (let element of elements) {
                                if (element.innerText.trim() || element.querySelector(contentSelectors)) {
                                    return { result: true };
                                }
                            }
                        }
                    }
                    
                    if (idArray.length > 0) {
                        for (let idName of idArray) {
                            let element = document.getElementById(idName);
                            if (element && (element.innerText.trim() || element.querySelector(contentSelectors))) {
                                return { result: true };
                            }
                        }
                    }
                } catch (error) {
                    console.error("Unexpected error in checkPageContent:", error);
                }
                return { result: false };
            }
            
            const classArray = ["content", "article"];
            const idArray = ["mainContent", "pageContainer"];
            return checkPageContent(classArray, idArray);
        });
        """
        webView.evaluateJavaScript(script) { result, error in
            if let json = result as? [String: Any] {
                completion(json)  // Returns an object with result boolean
            } else {
                completion(["result": false])  // Default to false if there's an error
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
