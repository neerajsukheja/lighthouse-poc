import fs from "fs";
import path from "path";
import puppeteer from "puppeteer";
import lighthouse from "lighthouse";
import { launch as launchChrome } from "chrome-launcher"; // Named import for chrome-launcher

const loginUrl = "https://md-ht-7.webhostbox.net:2083"; // Replace with your login URL
const urlsToTest = [
  {
    name: "Page1",
    url: "https://md-ht-7.webhostbox.net:2083/cpsess1256618553/frontend/jupiter/mail/filters/managefilters.html",
  },
  {
    name: "Page2",
    url: "https://md-ht-7.webhostbox.net:2083/cpsess1256618553/frontend/jupiter/domains/index.html",
  },
  // Add more objects with name and url here
];

async function authenticateAndGetCookies(page) {
  await page.goto(loginUrl, { waitUntil: "networkidle2" });
  await page.type("#user", "neerafeo", { delay: 500 });
  await page.type("#pass", "Not4any1!!", { delay: 500 });
  await page.click("#login_submit");
  await page.waitForNavigation();

  // Check if login was successful
  const currentUrl = page.url();
  if (!currentUrl.includes("frontend")) {
    console.log("Login failed");
    return null;
  }

  console.log("Login successful");
  return await page.cookies();
}

async function runLighthouse(name, url, port, cookies, jsonDir, htmlDir) {
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

  const results = await lighthouse(
    url,
    {
      port,
      output: ["json", "html"],
      logLevel: "info",
      onlyCategories: ["performance", "accessibility", "best-practices", "seo"],
      extraHeaders: {
        // Send cookies to Lighthouse for the authenticated session
        Cookie: cookies.map((c) => `${c.name}=${c.value}`).join("; "),
      },
    },
    lighthouseConfig
  );

  const jsonReport = results.report[0];
  const htmlReport = results.report[1];
  const timestamp = Date.now();

  // Save JSON report
  fs.writeFileSync(path.join(jsonDir, `${name}.json`), jsonReport);
  console.log(`Lighthouse JSON report for ${name} saved.`);

  // Save HTML report
  fs.writeFileSync(path.join(htmlDir, `${name}.html`), htmlReport);
  console.log(`Lighthouse HTML report for ${name} saved.`);
}

async function run() {
  let browser;
  let chrome;
  const timestamp = Date.now();
  const jsonDir = path.join(process.cwd(), `json-reports-${timestamp}`);
  const htmlDir = path.join(process.cwd(), `html-reports-${timestamp}`);

  try {
    // Create directories for reports
    fs.mkdirSync(jsonDir);
    fs.mkdirSync(htmlDir);

    // Launch Puppeteer
    browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();

    // Authenticate and get cookies
    const cookies = await authenticateAndGetCookies(page);
    if (!cookies) return;

    console.log("Starting Lighthouse audits...");

    // Launch Chrome for Lighthouse
    chrome = await launchChrome({ chromeFlags: ["--headless"] });

    // Iterate over URLs and run Lighthouse for each
    for (const { name, url } of urlsToTest) {
      await runLighthouse(name, url, chrome.port, cookies, jsonDir, htmlDir);
    }
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

run().catch((err) => {
  console.error("Error running Lighthouse:", err);
});
