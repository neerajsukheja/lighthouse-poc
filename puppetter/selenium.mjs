import fs from "fs";
import { Builder, By, until } from "selenium-webdriver";
import chrome from "selenium-webdriver/chrome";
import chromeLauncher from "chrome-launcher";
import lighthouse from "lighthouse";

(async () => {
  // Step 1: Set up Selenium WebDriver
  const driver = new Builder()
    .forBrowser("chrome")
    .setChromeOptions(new chrome.Options().headless()) // Run headless to avoid UI pop-ups
    .build();

  try {
    // Step 2: Navigate to the login page
    const loginUrl = "https://md-ht-7.webhostbox.net:2083"; // Replace with your login URL
    await driver.get(loginUrl);

    // Step 3: Authenticate (This example assumes a basic username/password form)
    await driver.findElement(By.id("user")).sendKeys("neerafeo");
    await driver.findElement(By.id("pass")).sendKeys("Not4any1!!");
    await driver.findElement(By.id("login_submit")).click();

    // Wait for the page to load after login
    await driver.wait(until.urlContains("dashboard"), 10000); // Adjust the wait as needed

    // Step 4: Get the cookies after login
    const cookies = await driver.manage().getCookies();

    // Convert cookies into Lighthouse-compatible format
    const cookieString = cookies
      .map((cookie) => `${cookie.name}=${cookie.value}`)
      .join("; ");

    // Step 5: Get the URL of the page to audit (after login)
    const currentUrl = await driver.getCurrentUrl(); // Replace with the authenticated page URL

    // Step 6: Launch Chrome and run Lighthouse
    const chromeFlags = ["--headless", "--no-sandbox", "--disable-gpu"];

    const chromeInstance = await chromeLauncher.launch({
      chromeFlags,
    });

    const lighthouseResult = await lighthouse(currentUrl, {
      port: chromeInstance.port,
      output: ["html", "json"],
      logLevel: "info",
      extraHeaders: {
        Cookie: cookieString, // Attach the cookies to Lighthouse request
      },
    });

    // Step 7: Write the Lighthouse reports to files (HTML and JSON)
    const htmlReport = lighthouseResult.report[0];
    const jsonReport = lighthouseResult.report[1];

    // Save the reports to the file system
    fs.writeFileSync("lighthouse-report.html", htmlReport);
    fs.writeFileSync("lighthouse-report.json", jsonReport);

    console.log("Lighthouse reports generated successfully!");

    // Close the Chrome instance after the audit is complete
    await chromeInstance.kill();
  } finally {
    // Close the Selenium WebDriver
    await driver.quit();
  }
})();
