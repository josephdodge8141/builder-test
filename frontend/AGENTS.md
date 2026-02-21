# Frontend AGENTS.md

## Overview

React frontend with TypeScript, Vite, Tailwind CSS, and Playwright for testing.

## Project Structure

```
frontend/
├── AGENTS.md                    # This file
├── Dockerfile                   # Container build
├── wait-and-release.sh          # Port allocation wrapper
├── start.sh                     # Service startup script
├── package.json                 # Dependencies and scripts
├── playwright.config.ts         # Playwright configuration
├── vite.config.ts               # Vite configuration
├── tailwind.config.js           # Tailwind CSS config
├── postcss.config.js            # PostCSS config
├── tsconfig.json                # TypeScript config
├── tsconfig.node.json          # Node TypeScript config
├── index.html                   # HTML entrypoint
├── src/
│   ├── main.tsx                 # React entrypoint
│   ├── App.tsx                  # Main app component
│   ├── index.css                # Global styles
│   ├── vite-env.d.ts            # Vite type definitions
│   ├── components/              # Shared components
│   │   └── Button/
│   │       ├── index.tsx
│   │       └── Button.tsx
│   ├── features/                # Feature modules (page-based)
│   │   ├── home/
│   │   │   ├── README.md        # REQUIRED: Product spec
│   │   │   ├── index.ts         # Feature exports
│   │   │   ├── HomePage.tsx     # Main page component
│   │   │   └── components/      # Feature-specific components
│   │   └── <page-name>/
│   │       ├── README.md        # REQUIRED: Product spec
│   │       ├── index.ts
│   │       ├── <PageName>Page.tsx
│   │       └── components/
│   └── api/                     # API client
│       └── client.ts
└── tests/
    ├── playwright.config.ts     # Test configuration
    └── <feature-name>.spec.ts   # Playwright tests
```

## Feature Development

### Process

1. **Create feature directory**: `src/features/<page-name>/`
2. **Create README.md**: Document product requirements (REQUIRED)
3. **Write Playwright test**: Describe expected user experience
4. **Implement code**: Build to pass the test
5. **Update test**: If requirements change, update test first

### Feature README Template

```markdown
# <Page Name>

## Overview
Brief description of what this page does and its purpose.

## Anticipated User Experience

### User Actions
- What the user can do on this page
- Step-by-step user flow

### Visual Feedback
- What the user sees after each action
- Loading states, success messages, error states

### Edge Cases
- What happens with empty data
- What happens with errors
- Loading states

## Design Spec

### Layout
- Page structure
- Responsive behavior

### Components Used
- List of components needed
- Any custom components specific to this feature

### Interactions
- Hover states
- Click behaviors
- Transitions/animations

### Data Display
- How data is presented
- Sorting/filtering behavior

## API Integration

### Endpoints Used
- `GET /api/v1/...`
- `POST /api/v1/...`

### Data Flow
- How data is fetched
- State management approach

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
```

## Components

- Create reusable components in `src/components/`
- Each component in its own directory
- Include `index.ts` for exports
- Use TypeScript for all components
- Use Tailwind CSS for styling

Example component structure:
```
src/components/Button/
├── index.ts
└── Button.tsx
```

## API Client

- Use `fetch` or `axios` for API calls
- Create typed client in `src/api/client.ts`
- Use environment variable for base URL: `import.meta.env.VITE_API_URL`

```typescript
// src/api/client.ts
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export async function fetchUsers() {
  const response = await fetch(`${API_URL}/api/v1/users`);
  if (!response.ok) throw new Error('Failed to fetch users');
  return response.json();
}
```

## Commands

### Format
```bash
npm run format
```

### Lint
```bash
npm run lint        # Check
npm run lint:fix   # Fix
```

### Typecheck
```bash
npm run typecheck
```

### Test (Playwright)
```bash
npx playwright test              # Run all tests
npx playwright test --ui         # UI mode
npx playwright test <file>       # Run specific file
npx playwright test --grep <pattern>  # Run matching tests
```

## Testing with Playwright

### Writing Tests

- Tests describe user experience, not implementation
- Test in `tests/` directory
- Name files as `<feature-name>.spec.ts`

Example:
```typescript
// tests/home.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Home Page', () => {
  test('should display welcome message', async ({ page }) => {
    await page.goto('/');
    await expect(page.getByText('Welcome')).toBeVisible();
  });

  test('should navigate to users page', async ({ page }) => {
    await page.goto('/');
    await page.click('text=Users');
    await expect(page).toHaveURL('/users');
  });
});
```

### Running Tests

```bash
# All tests
npx playwright test

# With UI (interactive)
npx playwright test --ui

# Specific file
npx playwright test tests/home.spec.ts

# Headless (CI)
npx playwright test --reporter=html
```

### Configuration

Edit `playwright.config.ts` to configure:
- Base URL
- Browser options
- Test timeout
- Reporter

## State Management

- Use React hooks (`useState`, `useEffect`) for local state
- Consider React Context for shared state
- Keep state as close to where it's used as possible

## Routing

- Use `react-router-dom` for routing
- Define routes in `App.tsx`

```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { HomePage } from './features/home';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
      </Routes>
    </BrowserRouter>
  );
}
```

## Environment Variables

- Use `.env` files for configuration
- Prefix frontend variables with `VITE_`
- Access via `import.meta.env.VITE_*`

```
VITE_API_URL=http://localhost:8000
```

## Build for Production

```bash
npm run build
```

This generates optimized files in `dist/`.
