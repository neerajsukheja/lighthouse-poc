import { Builder, By, until } from "selenium-webdriver";
import chrome from "selenium-webdriver/chrome.js"; // Ensure .js is added
import lighthouse from "lighthouse";
import { launch } from "chrome-launcher";
import fs from "fs";

const url = "YOUR_LOGIN_URL";
const username = "YOUR_USERNAME";
const password = "YOUR_PASSWORD";

async function runSeleniumAndLighthouse() {
  let options = new chrome.Options();
  options.addArguments(
    "--disable-gpu",
    "--no-sandbox",
    "--disable-dev-shm-usage",
    "--headless"
  );

  // Initialize Selenium WebDriver
  let driver = new Builder()
    .forBrowser("chrome")
    .setChromeOptions(options)
    .build();

  try {
    // Open login page
    await driver.get(url);

    // Perform login (update selectors as per your login page)
    await driver.findElement(By.name("username")).sendKeys(username);
    await driver.findElement(By.name("password")).sendKeys(password);
    await driver.findElement(By.css('button[type="submit"]')).click();

    // Wait for post-login page to load (update with a specific element or URL to wait for)
    await driver.wait(until.urlContains("dashboard"), 15000); // Adjust 'dashboard' to your specific post-login page

    const loggedInPageUrl = await driver.getCurrentUrl();

    // Launch Chrome for Lighthouse
    const chromeFlags = ["--headless", "--disable-gpu", "--no-sandbox"];
    const chromeInstance = await launch({ chromeFlags });

    // Run Lighthouse against the logged-in page
    const result = await lighthouse(loggedInPageUrl, {
      port: chromeInstance.port,
      output: "json",
      onlyCategories: ["performance", "accessibility", "best-practices", "seo"], // Customize categories
    });

    fs.writeFileSync("lighthouse-report.json", result.report);

    console.log("Lighthouse report generated successfully!");
  } catch (error) {
    console.error("Error during process:", error);
  } finally {
    await driver.quit();
  }
}

runSeleniumAndLighthouse();
