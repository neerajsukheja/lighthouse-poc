// Import Selenium WebDriver module
import { Builder, By, Key, until } from "selenium-webdriver";

// Main function to run the test
async function example() {
  // Setup Chrome browser (or use 'firefox' for Firefox)
  let driver = await new Builder().forBrowser("chrome").build();

  try {
    // Navigate to a website
    await driver.get("https://www.google.com");

    // Find the search box element by name and send a query
    await driver
      .findElement(By.name("q"))
      .sendKeys("Selenium WebDriver", Key.RETURN);

    // Wait for the results page to load and display the results
    await driver.wait(until.titleContains("Selenium WebDriver"), 1000);

    let currentUrl = await driver.getCurrentUrl();
    console.log(`Current page URL is: ${currentUrl}`);
    console.log("Test passed. Google search successful.");
  } finally {
    // Quit the browser after the automation
    await driver.quit();
  }
}

// Run the function
example();
