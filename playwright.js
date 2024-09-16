import { chromium } from "playwright";
import fs from "fs/promises";
import { launch as launchChrome } from "chrome-launcher"; // Named import for chrome-launcher
import CDP from "chrome-remote-interface";
import lighthouse from "lighthouse";
import path from "path";

async function authenticateAndGetFinalUrl() {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const loginUrl = "https://md-ht-7.webhostbox.net:2083";

  // Go to the login page
  await page.goto(loginUrl);

  // Perform the login
  await page.fill("#user", "neerafeo");
  await page.fill("#pass", "Not4any1!!");
  await page.click("#login_submit");

  // Wait for navigation or successful login
  await page.waitForNavigation();

  // Capture the final URL after login
  const finalUrl = page.url();

  // Get cookies after login
  const cookies = await page.context().cookies();
  await browser.close();

  return { finalUrl, cookies };
}

async function runLighthouse(url, cookies, projectName = "testProject") {
  const chrome = await launchChrome({ chromeFlags: ["--headless"] });
  const protocol = await CDP({ port: chrome.port });

  // Set cookies in the new browser instance
  await protocol.Network.setCookies({
    cookies: cookies.map((cookie) => ({
      name: cookie.name,
      value: cookie.value,
      domain: cookie.domain,
      path: cookie.path,
      expires: cookie.expires,
      httpOnly: cookie.httpOnly,
      secure: cookie.secure,
    })),
  });

  await protocol.close();

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
    port: chrome.port, // Use the same port for Lighthouse
    output: ["json", "html"],
    logLevel: "info",
    onlyCategories: ["performance", "accessibility", "best-practices", "seo"],
  };

  const runnerResult = await lighthouse(url, options, lighthouseConfig);
  const jsonReport = runnerResult.report[0];
  const htmlReport = runnerResult.report[1];

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
  await chrome.kill();

  return runnerResult.report;
}

(async () => {
  try {
    const { finalUrl, cookies } = await authenticateAndGetFinalUrl();
    console.log("Final URL after login:", finalUrl);

    const report = await runLighthouse(finalUrl, cookies);

    // Save the report to a file
    await fs.writeFile("lighthouse-report.html", report);
    console.log("Lighthouse report generated successfully");
  } catch (error) {
    console.error("Error generating Lighthouse report:", error);
  }
})();
