import { test, expect } from '@playwright/test';

/**
 * Example Playwright E2E test
 * 
 * This is a sample test file to demonstrate Playwright setup.
 * Replace this with your actual E2E tests.
 */
test('homepage loads successfully', async ({ page }) => {
  await page.goto('/');
  
  // Wait for the page to load
  await page.waitForLoadState('networkidle');
  
  // Example assertion - adjust based on your actual homepage content
  await expect(page).toHaveTitle(/Next.js/i);
});

test('example navigation test', async ({ page }) => {
  await page.goto('/');
  
  // Example: Check if a specific element exists
  // Replace with your actual selectors
  const body = page.locator('body');
  await expect(body).toBeVisible();
});
