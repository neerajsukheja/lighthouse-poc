import { Builder, By } from "selenium-webdriver";
import chrome from "selenium-webdriver/chrome.js";
import CDP from "chrome-remote-interface";
import lighthouse from "lighthouse";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

(async function openDevTools() {
  let options = new chrome.Options();
  options.addArguments("start-maximized");
  options.addArguments("remote-debugging-port=9222"); // Enable remote debugging

  let driver = await new Builder()
    .forBrowser("chrome")
    .setChromeOptions(options)
    .build();

  try {
    // Navigate to the target webpage
    await driver.get("https://md-ht-7.webhostbox.net:2083");
    // Perform login
    await driver.findElement(By.id("user")).sendKeys("neerafeo"); // Replace with actual username field selector
    await driver.findElement(By.id("pass")).sendKeys("Not4any1!!"); // Replace with actual password field selector
    await driver.findElement(By.id("login_submit")).click();

    // Wait for the page to load
    await driver.sleep(5000);
    const currentUrl = await driver.getCurrentUrl();
    // Connect to the Chrome DevTools Protocol
    const client = await CDP();

    // Open DevTools and run Lighthouse
    await client.Network.enable();
    await client.Page.enable();
    await client.Page.navigate({ url: currentUrl });
    await client.Page.loadEventFired();

    const lighthouseConfig = {
      extends: "lighthouse:default",
      settings: {
        emulatedFormFactor: "desktop",
        screenEmulation: {
          width: 1920,
          height: 1080,
          deviceScaleFactor: 1,
        },
      },
    };

    const options = {
      port: 9222, // Use the same port for Lighthouse
      output: ["json", "html"],
      logLevel: "info",
      onlyCategories: ["performance", "accessibility", "best-practices", "seo"],
    };

    const results = await lighthouse(currentUrl, options, lighthouseConfig);

    const jsonReport = results.report[0];
    const htmlReport = results.report[1];

    // Save JSON and HTML reports
    const timestamp = Date.now();
    fs.writeFileSync(
      path.join(process.cwd(), `lighthouse-report-${timestamp}.json`),
      jsonReport
    );
    console.log("Lighthouse JSON report saved.");

    fs.writeFileSync(
      path.join(process.cwd(), `lighthouse-report-${timestamp}.html`),
      htmlReport
    );
    console.log("Lighthouse JSON report saved.");

    await client.close();
  } catch (err) {
    console.error("Error:", err);
  } finally {
    await driver.quit();
  }
})();
