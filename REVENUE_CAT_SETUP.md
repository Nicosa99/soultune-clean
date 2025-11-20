# RevenueCat Integration Guide - SoulTune

Complete guide for managing subscriptions in SoulTune using RevenueCat.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [RevenueCat Dashboard Setup](#revenuecat-dashboard-setup)
4. [Configuration](#configuration)
5. [Usage Examples](#usage-examples)
6. [Testing](#testing)
7. [Production Checklist](#production-checklist)
8. [Troubleshooting](#troubleshooting)

---

## Overview

SoulTune uses **RevenueCat** for subscription management. RevenueCat provides:

- ✅ Cross-platform subscription handling (iOS, Android)
- ✅ Server-side receipt validation
- ✅ Real-time subscription status updates
- ✅ Built-in paywall UI
- ✅ Customer center for subscription management
- ✅ Analytics and revenue tracking
- ✅ Webhook support for integrations

### Architecture

```
User Interface
    ↓
Riverpod Providers (lib/shared/providers/premium_providers.dart)
    ↓
PremiumService (lib/shared/services/premium/premium_service.dart)
    ↓
RevenueCatService (lib/shared/services/premium/revenue_cat_service.dart)
    ↓
RevenueCat SDK (purchases_flutter)
    ↓
App Store / Google Play
```

---

## Installation

### 1. Dependencies

Already added to `pubspec.yaml`:

```yaml
dependencies:
  purchases_flutter: ^8.2.3        # Core RevenueCat SDK
  purchases_ui_flutter: ^8.2.3     # Paywall & Customer Center UI
```

### 2. Install Packages

```bash
flutter pub get
```

### 3. Android Configuration

No additional Android configuration needed! RevenueCat SDK handles Google Play Billing automatically.

### 4. iOS Configuration (when iOS support is added)

Add to `ios/Runner/Info.plist`:

```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

---

## RevenueCat Dashboard Setup

### Step 1: Create RevenueCat Account

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Sign up or log in
3. Create new project: **SoulTune**

### Step 2: Get API Keys

1. Navigate to **Project Settings** → **API Keys**
2. Copy keys:
   - **Test (Public) Key**: `test_YVgpnblAlLpIHOzxPrFlCyZQTES` (already configured)
   - **Production (Public) Key**: Use this for production builds

### Step 3: Configure Products

#### Google Play Store Setup

1. Go to **RevenueCat Dashboard** → **Products**
2. Create 3 products:

| Product ID | Type | Duration | Price |
|-----------|------|----------|-------|
| `monthly` | Subscription | 1 month | $4.99 |
| `yearly` | Subscription | 1 year | $29.99 |
| `lifetime` | Non-consumable | N/A | $69.99 |

3. In **Google Play Console**:
   - Create matching subscription products
   - Set billing periods
   - Enable free trials (7 days for monthly/yearly)
   - Set prices

4. Link products in RevenueCat:
   - **Products** → **Google Play** → **Add Product**
   - Enter product ID from Play Console
   - Save

#### App Store Setup (future)

1. In **App Store Connect**:
   - Create subscription group: "SoulTune Pro"
   - Add 3 subscriptions (monthly, yearly, lifetime)
2. Link in RevenueCat dashboard

### Step 4: Configure Entitlements

1. Go to **Entitlements** → **Create Entitlement**
2. Create entitlement: **`SoulTune Pro`**
3. Attach all 3 products to this entitlement:
   - monthly → SoulTune Pro
   - yearly → SoulTune Pro
   - lifetime → SoulTune Pro

### Step 5: Create Offerings

1. Go to **Offerings** → **Create Offering**
2. Create offering: **`default`**
3. Add 3 packages:

| Package ID | Product | Description |
|-----------|---------|-------------|
| `$rc_monthly` | monthly | Monthly subscription |
| `$rc_annual` | yearly | Annual subscription (BEST VALUE) |
| `$rc_lifetime` | lifetime | Lifetime access (Limited time) |

4. Set `$rc_annual` as **Default Package**

### Step 6: Configure Paywall (Remote Config)

RevenueCat Paywalls v4 supports remote configuration:

1. Go to **Paywalls** → **Create Paywall**
2. Configure template:
   - **Title**: "Unlock SoulTune Pro"
   - **Subtitle**: "Experience the full power of healing frequencies"
   - **Features**:
     - "✨ 23+ Advanced Frequency Presets"
     - "🧠 CIA Gateway Process (Focus 10-21)"
     - "🌌 Out-of-Body Experience Training"
     - "🎛️ Unlimited Custom Generator"
     - "🎵 Dual-Layer Audio (Music + Generator)"
     - "🌐 Browser - All Frequencies"
     - "📊 Usage Analytics & Insights"
   - **Call to Action**: "Start Free Trial"

3. Link offering: `default`
4. Save and activate

---

## Configuration

### Current API Key (Test Mode)

```dart
// lib/main.dart
await RevenueCatService.instance.initialize(
  apiKey: 'test_YVgpnblAlLpIHOzxPrFlCyZQTES',
);
```

### Production API Key

Before production release:

1. Get production API key from RevenueCat dashboard
2. Replace test key in `lib/main.dart`:

```dart
await RevenueCatService.instance.initialize(
  apiKey: 'YOUR_PRODUCTION_PUBLIC_KEY',
);
```

**⚠️ SECURITY NOTE**: Public API keys are safe to embed in apps. RevenueCat validates purchases server-side.

---

## Usage Examples

### 1. Check Premium Status

```dart
// Using stream (reactive)
final isPremiumAsync = ref.watch(isPremiumProvider);
isPremiumAsync.when(
  data: (isPremium) => isPremium ? PremiumContent() : FreeContent(),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);

// Using future (one-time check)
final isPremium = await ref.read(isPremiumFutureProvider.future);
if (isPremium) {
  // Show premium feature
}
```

### 2. Gate Features with PremiumGate

```dart
import 'package:soultune/shared/widgets/premium_gate.dart';

// Wrap any premium content
PremiumGate(
  feature: PremiumFeature.customGenerator,
  child: CustomGeneratorScreen(),
)
```

### 3. Show Paywall

```dart
import 'package:soultune/shared/widgets/premium_gate.dart';

// Method 1: Helper function
final upgraded = await showPaywall(
  context,
  feature: PremiumFeature.ciaGatewayPresets,
);

// Method 2: Direct navigation
Navigator.of(context).push(
  MaterialPageRoute<bool>(
    builder: (_) => PaywallScreen(
      feature: PremiumFeature.customGenerator,
    ),
    fullscreenDialog: true,
  ),
);
```

### 4. Premium Button (shows paywall if free)

```dart
import 'package:soultune/shared/widgets/premium_gate.dart';

PremiumButton(
  feature: PremiumFeature.customGenerator,
  onPressed: () {
    // This only runs if user is premium
    Navigator.push(context, CustomGeneratorRoute());
  },
  child: Text('Create Custom Preset'),
)
```

### 5. Lock Icon on Premium Content

```dart
import 'package:soultune/shared/widgets/premium_gate.dart';

Stack(
  children: [
    PresetCard(preset: ciaFocus21),
    Positioned(
      top: 8,
      right: 8,
      child: PremiumLockIcon(
        feature: PremiumFeature.ciaGatewayPresets,
      ),
    ),
  ],
)
```

### 6. PRO Badge

```dart
import 'package:soultune/shared/widgets/premium_gate.dart';

Row(
  children: [
    Text('Custom Generator'),
    PremiumBadge(),
  ],
)
```

### 7. Show Customer Center

```dart
import 'package:soultune/shared/widgets/customer_center.dart';

// In settings screen
CustomerCenterButton(), // Shows "Manage Subscription" for premium users

// Or manually:
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => CustomerCenterScreen(),
    fullscreenDialog: true,
  ),
);
```

### 8. Restore Purchases

```dart
final restored = await ref.read(restorePurchasesProvider.future);
if (restored) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Purchases restored!')),
  );
}
```

### 9. Get Subscription Info

```dart
final subscriptionAsync = ref.watch(activeSubscriptionProvider);
subscriptionAsync.when(
  data: (subscription) {
    if (subscription != null) {
      print('Type: ${subscription.type}'); // "Monthly", "Yearly", "Lifetime"
      print('Expires: ${subscription.expirationDate}');
      print('Will renew: ${subscription.willRenew}');
      print('Is trial: ${subscription.isTrial}');
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);
```

---

## Testing

### Test Mode (Current Setup)

With test API key, all purchases are sandbox:

- **Android**: Use Google Play Console test accounts
- **iOS**: Use App Store Sandbox accounts

### Testing Purchases

1. **Create Test User**:
   - Android: Google Play Console → License Testing
   - iOS: App Store Connect → Sandbox Testers

2. **Test Purchase Flow**:
   ```dart
   // Tap "Upgrade to Pro" in app
   // Select monthly/yearly/lifetime package
   // Complete test purchase
   // Verify premium features unlock
   ```

3. **Test Restore Purchases**:
   ```dart
   // Install app on second device
   // Tap "Restore Purchases"
   // Verify premium status restored
   ```

4. **Test Subscription Expiry**:
   - Sandbox subscriptions renew faster:
     - 1 month = 5 minutes
     - 1 year = 1 hour
   - Cancel subscription in test account
   - Wait for expiry
   - Verify app downgrades to free tier

### RevenueCat Dashboard Testing

1. Go to **Customer Lists** in dashboard
2. Search for test user by app user ID
3. View purchase history
4. Test granting entitlements manually

---

## Production Checklist

Before launching, complete these steps:

### 1. RevenueCat Configuration

- [ ] Replace test API key with production key in `lib/main.dart`
- [ ] Verify all products are created in App Store/Play Store
- [ ] Verify products linked in RevenueCat dashboard
- [ ] Verify "SoulTune Pro" entitlement is active
- [ ] Verify "default" offering is configured
- [ ] Test paywall displays correctly
- [ ] Configure webhooks (optional, for analytics)

### 2. App Store / Play Store

- [ ] **Google Play**: Enable in-app billing
- [ ] **Google Play**: Set up merchant account
- [ ] **Google Play**: Upload release APK with billing permissions
- [ ] **Google Play**: Activate subscription products
- [ ] **iOS**: Configure "Paid Applications" agreement
- [ ] **iOS**: Upload app binary with in-app purchase capability
- [ ] **iOS**: Submit subscriptions for review

### 3. Code Changes

- [ ] Update API key to production
- [ ] Run `dart run build_runner build` to generate providers
- [ ] Test all premium gates work correctly
- [ ] Test paywall shows correct pricing
- [ ] Test restore purchases works
- [ ] Test customer center works
- [ ] Add analytics events (optional)

### 4. Legal & Compliance

- [ ] Add Terms of Service URL
- [ ] Add Privacy Policy URL
- [ ] Add subscription terms (auto-renewal, cancellation policy)
- [ ] Add links in app settings and paywall

### 5. Testing

- [ ] Test purchase flow end-to-end
- [ ] Test on real device (not emulator)
- [ ] Test with real payment method (small purchase)
- [ ] Test restore purchases on second device
- [ ] Test subscription management in Play Store/App Store
- [ ] Test customer center functionality

---

## Troubleshooting

### Issue: "No offerings found"

**Cause**: Products not configured in RevenueCat dashboard

**Fix**:
1. Go to RevenueCat dashboard → **Offerings**
2. Create "default" offering
3. Add packages with product IDs
4. Wait 5 minutes for cache to update
5. Restart app

### Issue: "Purchase failed with error code 4"

**Cause**: Product not found in App Store/Play Store

**Fix**:
1. Verify product exists in Play Console/App Store Connect
2. Verify product ID matches exactly (case-sensitive)
3. Verify product is active/approved
4. Link product in RevenueCat dashboard

### Issue: Premium status not updating after purchase

**Cause**: Customer info cache not refreshing

**Fix**:
```dart
await ref.read(refreshPremiumStatusProvider.future);
```

### Issue: "User cancelled purchase" error

**Cause**: User tapped back/cancel during purchase

**Fix**: This is normal behavior. No action needed.

### Issue: Paywall not showing

**Cause**: Offering not configured

**Fix**:
1. Check RevenueCat dashboard → **Offerings**
2. Ensure "default" offering exists
3. Ensure offering has packages
4. Restart app

### Issue: RevenueCat initialization failed

**Cause**: Invalid API key or network issue

**Fix**:
1. Verify API key is correct
2. Check network connection
3. Check RevenueCat status page: https://status.revenuecat.com

---

## Additional Resources

- **RevenueCat Docs**: https://www.revenuecat.com/docs
- **Flutter Integration**: https://www.revenuecat.com/docs/getting-started/installation/flutter
- **Paywalls Guide**: https://www.revenuecat.com/docs/tools/paywalls
- **Customer Center**: https://www.revenuecat.com/docs/tools/customer-center
- **RevenueCat Dashboard**: https://app.revenuecat.com

---

## Next Steps

1. **Run code generation**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Test the integration**:
   ```bash
   flutter run
   ```

3. **Verify premium features gate correctly**

4. **Configure products in RevenueCat dashboard**

5. **Test purchase flow with sandbox account**

6. **Prepare for production launch**
