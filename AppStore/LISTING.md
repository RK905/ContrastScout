# App Store Connect — Contrast Scout

Use these fields in App Store Connect. Website URLs are filled after the Cloudflare deploy in this repo (`website/`).

## Identity

| Field | Value |
|---|---|
| Name | Contrast Scout |
| Subtitle (30 chars) | Craft color contrast notebook |
| Bundle ID | `com.geeksdobyte.ContrastScout` |
| SKU | `contrastscout` |
| Primary language | English (U.S.) |
| Category | Productivity |
| Secondary category | Graphics & Design |
| Content rights | No third-party content |
| Age rating | 4+ |
| Made for Kids | No |

Subtitle character count: "Craft color contrast notebook" = 29.

## Promo text (170 characters max)

Sample two real-world colors, see a plain-language contrast result, save swatches, and preview common color-vision differences — a workshop notebook, not a web tool.

Character count: 165.

## Description

Contrast Scout is a camera-assisted color notebook for makers choosing labels, thread, paint, or signage.

If you are color-vision-deficient, or you simply want a second opinion before you commit to vinyl, embroidery thread, or a painted sign, Contrast Scout helps you compare two physical colors in the real world — not in a sRGB mockup.

HOW IT WORKS
• Point the finder at a material and sample color A, then color B.
• See the contrast ratio plus a plain-language result: easy to tell apart, readable, large marks only, or may blend.
• Preview small labels and large lettering using your two samples.
• Save swatches in an on-device notebook.
• Simulate protanopia, deuteranopia, and tritanopia before you buy more paint or thread.
• Share a text report with HEX values, the ratio, and craft notes (Scout Unlock).

BUILT FOR THE BENCH
Most contrast checkers assume a website. Contrast Scout starts with the spool, the chip, or the sign in your hand. Sample with the camera, a photo, or the color picker. Everything is processed on your iPhone or iPad. There is no account and no photo upload.

SCOUT UNLOCK — $4.99 ONCE
Not a subscription. Unlock unlimited saved palettes and shareable text reports. The free notebook holds 8 swatches. Restore purchases with your Apple ID.

PLEASE READ
Readings are estimates affected by lighting, shadows, gloss, and camera white balance. Contrast Scout is not a safety, ADA, OSHA, or WCAG certification. Use it as a workshop notebook, not as a compliance stamp.

Privacy Policy and Support are linked from the app and from the Contrast Scout website.

## Keywords (100 characters max)

contrast,color blind,accessibility,wcag,thread,paint,label,signage,swatch,cvd,palette,maker,craft

Count the string without spaces after commas as App Store Connect stores it. Suggested 99 characters:

`contrast,colorblind,accessibility,wcag,thread,paint,label,sign,swatch,palette,maker,craft,cvd,hex`

## What's New (1.0)

First release. Sample two colors with the camera, see a contrast ratio and a plain-language craft result, save swatches, simulate common color-vision differences, and optionally unlock unlimited palettes plus a shareable text report.

## Reviewer notes (App Review Information)

Hello App Review,

Contrast Scout is a camera-assisted notebook for comparing colors on physical crafts (labels, thread, paint, signage).

CAMERA
The camera is used only to sample a color under the on-screen finder. Frames are processed on device and are never uploaded. Purpose string: “Contrast Scout uses the camera to sample colors from labels, thread, paint, and signage so you can compare contrast. Frames are processed on your device and are not uploaded.”

HOW TO TEST WITHOUT A STUDIO SETUP
1. Open Scout.
2. If the simulator has no camera, tap “Try an example” (navy label + cream thread) or use the photo / color picker in the toolbar.
3. Confirm the ratio, plain-language result, WCAG estimate checklist, and the lighting disclaimer.
4. Open Notebook and save a swatch. Free tier caps at 8 swatches.
5. Open Simulate and switch Protanopia / Deuteranopia / Tritanopia.
6. Share report is part of Scout Unlock (one-time $4.99, not a subscription).

IN-APP PURCHASE
Product ID: com.geeksdobyte.ContrastScout.unlock
Type: Non-consumable, $4.99
Unlocks: unlimited saved palettes + shareable text reports
Restore: More → Restore purchases
A StoreKit configuration file is included: ContrastScout/Products.storekit

NO ACCOUNT / NO TRACKING
There is no login. No analytics SDK. Privacy nutrition labels: data not collected.

POLICY NOTES (A4, G1)
Readings are estimates affected by lighting. The app states it is not a safety or accessibility certification. Please do not treat on-screen ratios as ADA/WCAG certification.

Demo: On first launch, Scout → “Try an example” if camera permission is denied.

Thank you.

## IAP metadata (App Store Connect → In-App Purchases)

| Field | Value |
|---|---|
| Type | Non-Consumable |
| Product ID | `com.geeksdobyte.ContrastScout.unlock` |
| Reference name | Scout Unlock |
| Price | USD 4.99 (or equivalent) |
| Display name | Scout Unlock |
| Description | Unlimited saved palettes and shareable contrast reports for labels, thread, paint, and signage. |
| Review screenshot | Use the paywall screenshot in AppStore/screenshots |
| Review notes | One-time unlock. Not a subscription. Restore Purchases is on the paywall and in More. |

## App Privacy (nutrition labels)

- Data collected: No
- Tracking: No
- Camera: used on device for color sampling; not linked to identity; not used for tracking

## Export compliance

Uses only HTTPS for the public website links and Apple StoreKit. ITSAppUsesNonExemptEncryption = NO (exempt / standard encryption).

## URLs (update after deploy)

| Field | URL |
|---|---|
| Marketing | https://contrast-scout.wahgwan.workers.dev |
| Privacy Policy | https://contrast-scout.wahgwan.workers.dev/privacy/ |
| Support | https://contrast-scout.wahgwan.workers.dev/support/ |
| Support email | support@geeksdobyte.com |

## Screenshots

Place files from `AppStore/screenshots/`:

iPhone 6.7":
1. 01-iphone-scout.png — camera finder sampling two craft colors
2. 02-iphone-result.png — ratio + plain-language result
3. 03-iphone-notebook.png — saved swatches
4. 04-iphone-simulate.png — color-vision simulation
5. 05-iphone-unlock.png — Scout Unlock paywall

iPad 13":
1. 01-ipad-scout.png — camera + result side by side

## Version

- Marketing version: 1.0
- Build: 1
- Deployment target: iOS 17
- Devices: iPhone and iPad
