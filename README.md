# AIInteriorDesign

Generated from niche `ai-interior-design` (AI Image, tier S, score 85).

**Utility:** Redesign a room from a photo in chosen styles
**Primary ASO keyword:** `ai interior design`
**Also target:** `room design`, `home design ai`, `redecorate`, `interior ai`
**Paywall hook:** Unlimited redesigns, more styles, HD

> High intent (people mid-renovation). img2img with style prompts.

## Build it

```bash
brew install xcodegen        # once
cd AIInteriorDesign
xcodegen generate
open AIInteriorDesign.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `ai-interior-design_yearly` and `ai-interior-design_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.aiinteriordesign`

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
