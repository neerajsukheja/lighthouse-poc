func checkWebViewContent(_ webView: WKWebView, completion: @escaping (Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {  // Wait for 7 seconds to ensure React loads
        let script = """
            (function() {
                let ignoredClasses = ['header', 'head'];

                function hasValidContent(element) {
                    if (!element || ignoredClasses.some(cls => element.classList.contains(cls))) {
                        return false; // Ignore this element and its children
                    }

                    let textContent = element.innerText.trim();
                    let images = element.getElementsByTagName('img').length;
                    let isVisible = !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length);

                    if ((textContent.length > 0 || images > 0) && isVisible) {
                        return true;
                    }

                    // Recursively check child elements
                    for (let child of element.children) {
                        if (hasValidContent(child)) {
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
                print("JavaScript Result:", hasContent)
                completion(hasContent);  // Returns true if content exists outside ignored divs, false otherwise
            } else {
                print("JavaScript Error:", error?.localizedDescription ?? "Unknown error")
                completion(false);  // Default to false if there's an error
            }
        }
    }
}
