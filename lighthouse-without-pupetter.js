import * as chromeLauncher from "chrome-launcher";
import { Builder, By, Key, until } from "selenium-webdriver";
import chrome from "selenium-webdriver/chrome.js"; // Ensure correct path with .js extension

(async function () {
  // Launch Chrome with default port
  const chromeInstance = await chromeLauncher.launch({
    chromeFlags: [
      "--headless",
      "--disable-gpu",
      "--remote-debugging-port=9222",
    ],
  });

  console.log("Chrome launched on port 9222");

  // Set up WebDriver with the default remote debugging port
  const chromeOptions = new chrome.Options().addArguments(
    "--remote-debugging-port=9222"
  );
  const driver = await new Builder()
    .forBrowser("chrome")
    .setChromeOptions(chromeOptions)
    .build();

  try {
    // Navigate to a website
    await driver.get("https://www.example.com");

    // Get and print the current page URL
    const currentUrl = await driver.getCurrentUrl();
    console.log(`Current page URL is: ${currentUrl}`);
  } finally {
    await driver.quit();
    await chromeInstance.kill(); // Kill the Chrome process
  }
})();
