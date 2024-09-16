import { Builder, By } from "selenium-webdriver";
import { launch } from "chrome-launcher";
import lighthouse from "lighthouse";
import fs from "fs";
import path from "path";

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

// Function to run Lighthouse
async function runLighthouse(url, projectName) {
  // Launch Chrome
  const chrome = await launch({ chromeFlags: ["--headless"] });

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
    port: chrome.port,
    output: ["json", "html"],
    logLevel: "info",
    onlyCategories: ["performance", "accessibility", "best-practices", "seo"],
  };

  try {
    // Run Lighthouse
    const results = await lighthouse(url, options, lighthouseConfig);
    const jsonReport = results.report[0];
    const htmlReport = results.report[1];

    const timestamp = Date.now();
    const jsonDir = path.join(process.cwd(), "json");
    const htmlDir = path.join(process.cwd(), "html");

    // Create directories if they don't exist
    if (!fs.existsSync(jsonDir)) {
      fs.mkdirSync(jsonDir);
    }
    if (!fs.existsSync(htmlDir)) {
      fs.mkdirSync(htmlDir);
    }

    // Save JSON report
    fs.writeFileSync(
      path.join(jsonDir, `${projectName}-${timestamp}.json`),
      jsonReport
    );
    console.log("Lighthouse JSON report saved.");

    // Save HTML report
    fs.writeFileSync(
      path.join(htmlDir, `${projectName}-${timestamp}.html`),
      htmlReport
    );
    console.log("Lighthouse HTML report saved.");
  } catch (error) {
    console.error("Error running Lighthouse:", error);
  } finally {
    // Stop Chrome
    await chrome.kill();
  }
}

// Main function to run the test
async function example() {
  const projectName = "myProject"; // Set your project name here
  let driver = await new Builder().forBrowser("chrome").build();

  try {
    // Navigate to the login page
    await driver.get("https://example.com"); // Replace with actual login URL

    // Perform login
    await driver.findElement(By.id("user")).sendKeys(""); // Replace with actual username field selector
    await driver.findElement(By.id("pass")).sendKeys(""); // Replace with actual password field selector
    await driver.findElement(By.id("login_submit")).click();

    // Wait for the login to complete and redirect to the post-login page
    // await driver.wait(until.elementLocated(By.id('someElementId')), 10000);
    // await driver.wait(until.elementIsVisible(driver.findElement(By.id('someElementId'))), 10000);
    // await driver.wait(until.urlContains("expected-url-part"), 10000);

    // Navigate to the desired page
    //await driver.get("https://example.com/dashboard"); // Replace with the post-login URL if necessary

    // Wait for the login to complete
    await sleep(10000); // Adjust sleep as necessary

    // Get the current URL
    const currentUrl = await driver.getCurrentUrl();
    console.log(`Current page URL is: ${currentUrl}`);

    // Run Lighthouse on the current URL
    await runLighthouse(currentUrl, projectName);
  } finally {
    // Quit the browser after the automation
    await driver.quit();
  }
}

// Run the function
example().catch((err) => console.error("Error:", err));
