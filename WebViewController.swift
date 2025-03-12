import SwiftUI
import WebKit

struct ContentView: View {
    @State private var showWebView = false
    
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

struct WebViewScreen: View {
    @Binding var showWebView: Bool
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            WebView(urlString: "http://localhost:3000", showAlert: $showAlert)
                .navigationTitle("WebView")
                .navigationBarItems(leading: Button("Back") {
                    showWebView = false
                })
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("No Content Available"), message: nil, dismissButton: .default(Text("OK")))
                }
        }
    }
}

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
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.innerText.trim().length > 0 || document.images.length > 0") { result, error in
                if let hasContent = result as? Bool, !hasContent {
                    DispatchQueue.main.async {
                        self.parent.showAlert = true
                    }
                }
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
