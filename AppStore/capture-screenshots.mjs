import { chromium } from "playwright";
import { mkdir } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const html = resolve(root, "mockups/screenshots.html");
const out = resolve(root, "screenshots");
await mkdir(out, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: 2048, height: 2796 },
  deviceScaleFactor: 1,
});
await page.goto(`file://${html}`);
await page.waitForTimeout(300);

const shots = [
  ["s1", "01-iphone-scout.png"],
  ["s2", "02-iphone-result.png"],
  ["s3", "03-iphone-notebook.png"],
  ["s4", "04-iphone-simulate.png"],
  ["s5", "05-iphone-unlock.png"],
  ["ipad", "01-ipad-scout.png"],
];

for (const [id, name] of shots) {
  const el = page.locator(`#${id}`);
  await el.screenshot({ path: resolve(out, name), type: "png" });
  console.log("wrote", name);
}

await browser.close();
