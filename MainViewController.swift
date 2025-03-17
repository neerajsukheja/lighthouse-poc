func checkWebViewContent(_ webView: WKWebView, completion: @escaping (Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {  // Wait for 7 seconds to ensure React loads
        let script = """
            (function() {
                let ignoredClasses = ['header', 'head', 'logo'];
                
                function hasValidContent(element) {
                    if (!element) return false;

                    // Get class names as an array
                    var classNames = element.className ? element.className.split(" ") : [];

                    // If the element has a class that should be ignored, skip it
                    if (ignoredClasses.some(cls => classNames.includes(cls))) {
                        return false;
                    }

                    // Check if the element has text content
                    if (element.nodeType === 3) { // Node.TEXT_NODE (3)
                        var text = element.nodeValue.trim();
                        if (text.length > 0) {
                            return true;
                        }
                    }

                    // Check if the element is an image
                    if (element.tagName && element.tagName.toLowerCase() === "img" && element.src) {
                        return true;
                    }

                    // Recursively check child nodes
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
                print("JavaScript Result:", hasContent)
                completion(hasContent);  // Returns true if content exists outside ignored divs, false otherwise
            } else {
                print("JavaScript Error:", error?.localizedDescription ?? "Unknown error")
                completion(false);  // Default to false if there's an error
            }
        }
    }
}
