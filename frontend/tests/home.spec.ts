import { test, expect } from '@playwright/test';

test.describe('Home Page', () => {
  test('should display welcome message', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByText('Welcome')).toBeVisible();
  });

  test('should display application description', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByText('Your application is running')).toBeVisible();
  });

  test('should have no console errors', async ({ page }) => {
    const consoleErrors: string[] = [];
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    await page.goto('/');
    await page.waitForLoadState('networkidle');

    expect(consoleErrors).toHaveLength(0);
  });
});
