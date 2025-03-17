let script = """
            (function() {
                let ignoredClasses = ['header', 'head'];
                let elements = document.body.children;
                
                for (let i = 0; i < elements.length; i++) {
                    let element = elements[i];
                    let classList = Array.from(element.classList);
                    
                    if (!classList.some(cls => ignoredClasses.includes(cls))) {
                        let textContent = element.innerText.trim();
                        let images = element.getElementsByTagName('img').length;
                        
                        if (textContent.length > 0 || images > 0) {
                            return true;
                        }
                    }
                }
                return false;
            })()
        """;
