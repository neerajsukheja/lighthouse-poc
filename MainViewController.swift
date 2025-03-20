document.addEventListener("DOMContentLoaded", function () {
    function checkPageContent(classArray = [], idArray = []) {
        try {
            const contentSelectors = "img, video, canvas, form, iframe, embed, object, audio, picture, svg, map, source, track, blockquote, cite, button, label, select, textarea, table, th, td, ul, ol, li";
            const errorMessages = new Set([
                "Webpage not available",
                "net::ERR_CONNECTION_REFUSED",
                "This site can’t be reached"
            ]);

            // Check for error messages in the page
            if (errorMessages.has(document.body.innerText.trim())) {
                return { "result": false };
            }

            // Optimized regex pattern for wildcard class matching
           const wildcardRegex = classArray.length ? new RegExp(`^(${classArray.join('|')})([\\w-]*)?$`) : null;

            // Check if content exists in elements with matching classes
            for (let element of document.querySelectorAll("[class]")) {
                if ([...element.classList].some(cls => wildcardRegex && wildcardRegex.test(cls)) && 
                    (element.innerText.trim() || element.querySelector(contentSelectors))) {
                    return { "result": true };
                }
            }

            // Check if content exists in the specified id elements
            for (let idName of idArray) {
                let element = document.getElementById(idName);
                if (element && (element.innerText.trim() || element.querySelector(contentSelectors))) {
                    return { "result": true };
                }
            }

            for (let dataAttr of dataAttrArray) {
                let elements = document.querySelectorAll(`[${dataAttr}]`);
                for (let element of elements) {
                    if (element.innerText.trim() || element.querySelector(contentSelectors)) {
                        return { "result": true };
                    }
                }
            }
        } catch (error) {
            console.error("Unexpected error in checkPageContent:", error);
        }
        return { "result": false };
    }

    // Example usage - replace with actual class names and ids as needed
    const classArray = ["content", "main", "article"];
    const idArray = ["mainContent", "pageContainer"];
    console.log(checkPageContent(classArray, idArray));
});
