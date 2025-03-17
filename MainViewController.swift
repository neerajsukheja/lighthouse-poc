let script = """
            (function() {
                let ignoredClasses = ['header', 'head'];
                let allElements = document.body.getElementsByTagName('*');
                
                for (let i = 0; i < allElements.length; i++) {
                    let element = allElements[i];
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
