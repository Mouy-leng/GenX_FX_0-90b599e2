## 2024-05-23 - Status Indicators
**Learning:** Pure color (red/green) status indicators are inaccessible to color-blind users. Adding shape-based indicators (icons) significantly improves clarity.
**Action:** Always pair status colors with semantic icons (Check/Alert/X) or text labels.

## 2024-05-24 - Semantic Lists
**Learning:** In a list of "success" items, a partial success or warning can be easily missed if it shares the same icon. Differentiating it with a distinct icon (warning vs check) improves scannability and honesty.
**Action:** When displaying lists of status items, ensure non-perfect states are visually distinct, even if they are technically "passed" but with caveats.

## 2024-05-25 - Screen Reader Context for Status Icons
**Learning:** Visual status icons (Check/Alert) paired with text descriptions often lack explicit status announcement for screen readers (e.g., reading "Configuration fixed" instead of "Success: Configuration fixed").
**Action:** Use `sr-only` prefix text (Success/Warning) alongside status icons to ensure the state is explicitly conveyed to non-visual users.

## 2024-05-26 - Action Feedback Latency
**Learning:** In critical financial actions (like payments), lack of immediate visual feedback during network latency causes anxiety and double-submissions. A simple spinner transforms "did it work?" into "it's working."
**Action:** Always include a disabled loading state with a spinner for primary form actions.
