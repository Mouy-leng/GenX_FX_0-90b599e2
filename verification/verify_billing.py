from playwright.sync_api import sync_playwright, expect

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    page = browser.new_page()

    # Navigate to Billing page
    page.goto("http://localhost:5173/billing")

    # 1. Verify Initial State (Asterisks should be visible)
    page.screenshot(path="verification/billing_initial.png")
    print("Initial screenshot taken.")

    # 2. Trigger Validation Errors
    page.get_by_role("button", name="Add Payment Method").click()

    # Wait for error messages to appear
    expect(page.get_by_text("Cardholder name is required")).to_be_visible()

    page.screenshot(path="verification/billing_validation.png")
    print("Validation screenshot taken.")

    # 3. Verify Success State (Mock API)
    # Mock the API response
    # Use generic pattern to catch potential query params or differences
    page.route("**/api/v1/billing", lambda route: route.fulfill(
        status=200,
        body='{"success": true}',
        headers={"Content-Type": "application/json"}
    ))

    # Fill the form - trying exact text match including the asterisk just in case,
    # but strictly speaking aria-hidden should hide it.
    # Let's use get_by_role("textbox") and filter if needed, or stick to label.
    # If aria-hidden works, "Cardholder Name" should work.

    # Debug: Check what's happening
    try:
        page.get_by_label("Cardholder Name").fill("John Doe")
        page.get_by_label("Card Number").fill("1234567812345678")
        page.get_by_label("Expiry Date").fill("12/25")
        page.get_by_label("CVC").fill("123")
    except Exception as e:
        print(f"Error filling form: {e}")
        # Fallback to selectors if labels are tricky with the new DOM structure
        page.locator("#cardholderName").fill("John Doe")
        page.locator("#cardNumber").fill("1234567812345678")
        page.locator("#expiryDate").fill("12/25")
        page.locator("#cvc").fill("123")

    page.screenshot(path="verification/billing_filled.png")
    print("Filled form screenshot taken.")

    # Submit
    page.get_by_role("button", name="Add Payment Method").click()

    # Wait for success message
    # Increase timeout just in case
    try:
        expect(page.get_by_text("Payment method added successfully")).to_be_visible(timeout=10000)
        page.screenshot(path="verification/billing_success.png")
        print("Success screenshot taken.")
    except Exception as e:
        print(f"Error waiting for success: {e}")
        page.screenshot(path="verification/billing_failed.png")

    browser.close()

with sync_playwright() as playwright:
    run(playwright)
