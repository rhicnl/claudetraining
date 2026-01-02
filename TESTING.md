# Testing Guide

This project is configured to run both unit tests (Jest) and end-to-end tests (Playwright).

## Setup

First, install all dependencies:

```bash
npm install
```

For Playwright, you'll also need to install the browser binaries:

```bash
npx playwright install
```

## Unit Tests (Jest)

Jest is configured to work with Next.js, React, and TypeScript.

### Running Tests

```bash
# Run all tests once
npm test

# Run tests in watch mode (re-runs on file changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

### Test Files

- Unit tests should be placed in `__tests__/` directories or alongside source files with `.test.ts` or `.test.tsx` extensions
- Example test file: `__tests__/example.test.tsx`

### Writing Tests

Use React Testing Library for component testing:

```tsx
import { render, screen } from '@testing-library/react';
import MyComponent from './MyComponent';

test('renders component', () => {
  render(<MyComponent />);
  expect(screen.getByText('Hello')).toBeInTheDocument();
});
```

## End-to-End Tests (Playwright)

Playwright is configured to test your application across multiple browsers.

### Running E2E Tests

```bash
# Run all E2E tests
npm run test:e2e

# Run E2E tests with UI mode (interactive)
npm run test:e2e:ui

# Run E2E tests in debug mode
npm run test:e2e:debug

# Generate test code by recording interactions
npm run test:e2e:codegen
```

### Test Files

- E2E tests should be placed in the `e2e/` directory
- Test files should have `.spec.ts` extension
- Example test file: `e2e/example.spec.ts`

### Writing E2E Tests

```typescript
import { test, expect } from '@playwright/test';

test('homepage loads', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Next.js/i);
});
```

### Configuration

- Playwright config: `playwright.config.ts`
- Base URL: `http://localhost:3000` (configurable via `PLAYWRIGHT_TEST_BASE_URL` env var)
- The dev server will automatically start before running tests

## Test Coverage

Coverage reports are generated in the `coverage/` directory when running `npm run test:coverage`.

## CI/CD

Both Jest and Playwright are configured to work in CI environments:
- Jest: Standard configuration
- Playwright: Retries enabled, single worker, trace collection on retry
