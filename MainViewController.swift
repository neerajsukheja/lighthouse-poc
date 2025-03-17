func checkWebViewContent(_ webView: WKWebView, completion: @escaping (Bool) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {  // Wait for 7 seconds to ensure React loads
        let script = """
            (function() {
                let ignoredClasses = ['header', 'head'];
                let body = document.body;
                if (!body) return false;  // If body is null, return false

                let allElements = body.getElementsByTagName('*');
                console.log("Total elements found: ", allElements.length);

                for (let i = 0; i < allElements.length; i++) {
                    let element = allElements[i];
                    let classList = Array.from(element.classList);
                    
                    if (!classList.some(cls => ignoredClasses.includes(cls))) {
                        let textContent = element.innerText.trim();
                        let images = element.getElementsByTagName('img').length;
                        let isVisible = !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length);
                        
                        console.log("Element Checked: ", element.tagName, "Visible:", isVisible, "Text:", textContent);

                        if ((textContent.length > 0 || images > 0) && isVisible) {
                            return true;
                        }
                    }
                }
                return false;
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
