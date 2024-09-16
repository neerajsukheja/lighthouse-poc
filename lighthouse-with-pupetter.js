import fs from "fs";
import path from "path";
import puppeteer from "puppeteer-core"; // Use puppeteer-core
import lighthouse from "lighthouse";
import { launch as launchChrome } from "chrome-launcher"; // Named import for chrome-launcher

const url = "https://md-ht-7.webhostbox.net:2083"; // Replace with your login URL

const chromePath = {
  mac: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  linux: "/usr/bin/google-chrome",
  windows: "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe", // Windows path (escape backslashes)
};

// Detect the current operating system
const os = process.platform;
const executablePath =
  os === "darwin"
    ? chromePath.mac
    : os === "win32"
    ? chromePath.windows
    : chromePath.linux;

async function runLighthouse(url) {
  let browser;
  let chrome;

  try {
    // Launch Puppeteer
    browser = await puppeteer.launch({ headless: true, executablePath });
    const page = await browser.newPage();

    // Set viewport to desktop dimensions (1920x1080)
    await page.setViewport({
      width: 1920,
      height: 1080,
      deviceScaleFactor: 1,
      isMobile: false,
      hasTouch: false,
      isLandscape: true,
    });

    // Go to the login page
    await page.goto(url, { waitUntil: "networkidle2" });
    await page.screenshot({ path: "screenshot-login.png", fullPage: true });

    // Click login button
    //await page.waitForSelector("#login-btn-exp");
    //await page.click("#login-btn-exp");

    //await page.waitForSelector("input[type='text']"); // Wait for email input to be visible
    //await page.waitForSelector("input[type='password']");
    // Set values directly via evaluate

    // Automate login
    await page.type("#user", "neerafeo", {
      delay: 500,
    }); // Add delay to simulate human typing
    await page.type("#pass", "Not4any1!!", {
      delay: 500,
    });
    /*
    await page.evaluate(() => {
      const emailInput = document.querySelector("input[type='text']");
      const passwordInput = document.querySelector("input[type='password']");
      if (emailInput) emailInput.value = "sdean";
      if (passwordInput) passwordInput.value = "ASimple1";
    });
    */
    await page.screenshot({
      path: "screenshot-afterlogin0.png",
      fullPage: true,
    });
    await page.click("#login_submit");
    await page.waitForNavigation();
    await page.screenshot({
      path: "screenshot-afterlogin1.png",
      fullPage: true,
    });
    // Check if login was successful
    const currentUrl = page.url();
    if (!currentUrl.includes("frontend")) {
      await page.screenshot({
        path: "screenshot-afterlogin2.png",
        fullPage: true,
      });
      console.log("Login failed");
      return;
    }

    console.log("Login successful, running Lighthouse audit...");

    // Launch Chrome for Lighthouse
    chrome = await launchChrome({ chromeFlags: ["--headless"] });

    // Define Lighthouse configuration settings
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
    // Run Lighthouse
    const results = await lighthouse(
      currentUrl,
      {
        port: chrome.port,
        output: ["json", "html"],
        logLevel: "info",
        onlyCategories: [
          "performance",
          "accessibility",
          "best-practices",
          "seo",
        ],
        extraHeaders: {
          // Send cookies to Lighthouse for the authenticated session
          Cookie: (await page.cookies())
            .map((c) => `${c.name}=${c.value}`)
            .join("; "),
        },
      },
      lighthouseConfig
    );

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
    console.log("Lighthouse HTML report saved.");
  } catch (err) {
    console.error("Error running Lighthouse:", err);
  } finally {
    // Close Chrome and Puppeteer
    if (chrome) {
      await chrome.kill();
    }
    if (browser) {
      await browser.close();
    }
  }
}

runLighthouse(url).catch((err) => {
  console.error("Error running Lighthouse:", err);
});
