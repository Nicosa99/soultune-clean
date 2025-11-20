# RevenueCat Setup Guide

Complete guide for integrating RevenueCat subscriptions into SoulTune.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Dashboard Configuration](#dashboard-configuration)
4. [App Configuration](#app-configuration)
5. [Testing](#testing)
6. [Production Deployment](#production-deployment)
7. [Common Issues](#common-issues)

---

## Overview

SoulTune uses RevenueCat for subscription management with three tiers:

- **Monthly**: $4.99/month (`monthly`)
- **Yearly**: $29.99/year (`yearly`)
- **Lifetime**: $69.99 one-time (`lifetime`)

**Entitlement**: `SoulTune Pro`

---

## Prerequisites

### 1. RevenueCat Account

✅ Already created with test API key: `test_YVgpnblAlLpIHOzxPrFlCyZQTES`

### 2. Google Play Console Access

- App must be created in Play Console
- Billing must be enabled
- Subscription products created

### 3. Flutter Environment

```bash
flutter pub get
```

Dependencies already added:
- `purchases_flutter: ^7.4.0`
- `purchases_ui_flutter: ^7.4.0`

---

## Dashboard Configuration

### Step 1: Create App in RevenueCat

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Click **"Create New App"**
3. Name: **SoulTune**
4. Platform: **Android** (add iOS later)
5. Save

### Step 2: Configure Products

#### 2.1 Create Products

Navigate to **Products** in dashboard:

**Product 1: Monthly Subscription**
- Product ID: `monthly`
- Type: Subscription
- Duration: 1 month
- Price: $4.99

**Product 2: Yearly Subscription**
- Product ID: `yearly`
- Type: Subscription
- Duration: 1 year
- Price: $29.99
- **Free Trial**: 7 days (optional)

**Product 3: Lifetime**
- Product ID: `lifetime`
- Type: Non-consumable
- Price: $69.99

#### 2.2 Create Entitlement

Navigate to **Entitlements**:

1. Click **"New Entitlement"**
2. Identifier: `SoulTune Pro`
3. Description: "Unlock all premium features"
4. Attach products:
   - ✅ monthly
   - ✅ yearly
   - ✅ lifetime

### Step 3: Create Offering

Navigate to **Offerings**:

1. Click **"New Offering"**
2. Identifier: `default`
3. Description: "SoulTune Premium"
4. Add packages:
   - Monthly ($4.99/month)
   - Yearly ($29.99/year) - **Mark as default**
   - Lifetime ($69.99)

### Step 4: Configure Paywall (Optional)

Navigate to **Paywalls** (RevenueCat v4+):

1. Create new paywall
2. Choose template (e.g., "Pricing List")
3. Customize:
   - Title: "Unlock Full SoulTune Experience"
   - Benefits:
     - All Solfeggio frequencies (174-963 Hz)
     - 20+ meditation presets
     - CIA Gateway Protocol
     - OBE & Remote Viewing sessions
     - Ad-free experience
4. Save and publish

---

## App Configuration

### 1. Update API Keys

Current configuration in `lib/shared/services/premium/revenuecat_config.dart`:

```dart
// Test key (already configured)
static const String testApiKeyAndroid = 'test_YVgpnblAlLpIHOzxPrFlCyZQTES';

// For production, set via environment variable
static const String? productionApiKeyAndroid =
    String.fromEnvironment('RC_ANDROID_KEY');
```

### 2. Switch to Production Service

In `lib/shared/services/premium/premium_providers.dart`:

```dart
// Change this to false for production
const bool _useMockService = false; // ← Set to false
```

### 3. Configure Google Play Products

#### 3.1 Create Subscriptions in Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select **SoulTune** app
3. Navigate to **Monetize** → **Subscriptions**
4. Click **"Create subscription"**

**Monthly Subscription:**
- Product ID: `monthly` (must match RevenueCat)
- Name: SoulTune Premium Monthly
- Description: "Unlock all healing frequencies and meditation protocols"
- Price: $4.99
- Billing period: 1 month
- Free trial: None

**Yearly Subscription:**
- Product ID: `yearly` (must match RevenueCat)
- Name: SoulTune Premium Yearly
- Description: "Unlock all healing frequencies and meditation protocols. Save 50%!"
- Price: $29.99
- Billing period: 1 year
- Free trial: 7 days (optional)

**Lifetime Purchase:**
- Navigate to **Monetize** → **In-app products**
- Product ID: `lifetime` (must match RevenueCat)
- Name: SoulTune Premium Lifetime
- Description: "One-time payment for lifetime access to all premium features"
- Price: $69.99

#### 3.2 Link Products to RevenueCat

1. Go to RevenueCat Dashboard
2. Navigate to **Project Settings** → **Google Play**
3. Upload Google Play service account JSON
4. Products should auto-sync

---

## Testing

### 1. Test with Mock Service (Development)

```dart
// In premium_providers.dart
const bool _useMockService = true;

// In your app
final service = ref.read(premiumServiceProvider) as MockPremiumService;
service.forcePremium(); // Instantly activates premium
```

### 2. Test with RevenueCat Sandbox

```dart
// In premium_providers.dart
const bool _useMockService = false;

// In revenuecat_config.dart
static const bool useTesting = true; // Uses test API key
```

**Setup sandbox tester:**

1. Go to Google Play Console → **Testing** → **License testing**
2. Add your Gmail account
3. Set license response to **RESPOND_NORMALLY**
4. Install app from Play Console internal testing track

**Test purchases:**

```dart
// Purchases will not charge real money
await service.purchaseAnnual();
```

### 3. Verify Purchase Flow

```dart
// Watch premium status
ref.watch(isPremiumProvider).when(
  data: (isPremium) => Text(isPremium ? 'Premium ✅' : 'Free'),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Text('Error'),
);

// Make purchase
final purchaseAction = ref.read(purchaseAnnualActionProvider);
final success = await purchaseAction();

print('Purchase successful: $success');
```

### 4. Test Customer Center

```dart
import 'package:soultune/shared/services/premium/customer_center_helper.dart';

// Show subscription management
CustomerCenterHelper.show(context);
```

---

## Production Deployment

### Step 1: Get Production API Key

1. Go to RevenueCat Dashboard
2. Navigate to **Project Settings** → **API Keys**
3. Copy **Production Android** key
4. Store securely (DO NOT commit to Git!)

### Step 2: Configure Environment Variables

**Option A: CI/CD Environment Variable**

```bash
# In GitHub Actions, CircleCI, etc.
export RC_ANDROID_KEY="pk_live_xxxxxxxxxxxxx"

# Build with environment variable
flutter build apk --release --dart-define=RC_ANDROID_KEY=$RC_ANDROID_KEY
```

**Option B: Local .env file (NOT committed)**

```bash
# .env file (add to .gitignore!)
RC_ANDROID_KEY=pk_live_xxxxxxxxxxxxx
```

### Step 3: Update Configuration

```dart
// In revenuecat_config.dart
static const bool useTesting = false; // ← Production mode

// In premium_providers.dart
const bool _useMockService = false; // ← Use RevenueCat
```

### Step 4: Build Release

```bash
# Clean build
flutter clean
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk --release \
  --dart-define=RC_ANDROID_KEY=your_production_key_here

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Step 5: Upload to Play Console

1. Go to Play Console → **Production** → **Create new release**
2. Upload `app-release.apk`
3. Fill out release notes
4. Submit for review

---

## Common Issues

### Issue 1: "No offerings available"

**Cause**: Products not synced between Play Console and RevenueCat

**Fix**:
1. Check Play Console products are **published**
2. Verify product IDs match exactly
3. In RevenueCat, go to **Google Play** settings and re-sync
4. Wait 5-10 minutes for sync

### Issue 2: Purchase fails with "Product not found"

**Cause**: Product ID mismatch

**Fix**:
```dart
// Verify product IDs match in all 3 places:
// 1. Google Play Console
// 2. RevenueCat Dashboard
// 3. revenuecat_config.dart
static const String productIdMonthly = 'monthly';
static const String productIdYearly = 'yearly';
static const String productIdLifetime = 'lifetime';
```

### Issue 3: "Invalid API key"

**Cause**: Wrong API key or not initialized

**Fix**:
```dart
// Verify in revenuecat_config.dart
static const String testApiKeyAndroid = 'test_YVgpnblAlLpIHOzxPrFlCyZQTES';

// Check initialization in logs
// Should see: "✅ RevenueCat SDK initialized"
```

### Issue 4: Free trial not working

**Cause**: Trial configured in Play Console but not in RevenueCat

**Fix**:
1. In Play Console → Subscription → Enable free trial (7 days)
2. In RevenueCat → Products → Edit product → Set trial period
3. Both must match

### Issue 5: Customer Center not opening

**Cause**: Missing Customer Center configuration

**Fix**:
1. Ensure `purchases_ui_flutter` is in `pubspec.yaml`
2. Verify RevenueCat Dashboard has Customer Center enabled
3. Check logs for specific error

---

## Verification Checklist

Before launch, verify:

- [ ] RevenueCat Dashboard configured
  - [ ] App created
  - [ ] Products created (monthly, yearly, lifetime)
  - [ ] Entitlement created (SoulTune Pro)
  - [ ] Offering created (default)

- [ ] Google Play Console configured
  - [ ] Subscriptions created
  - [ ] In-app products created
  - [ ] Prices set correctly
  - [ ] Service account linked to RevenueCat

- [ ] App Configuration
  - [ ] Production API key set (via environment variable)
  - [ ] `_useMockService = false`
  - [ ] `useTesting = false`
  - [ ] Product IDs match everywhere

- [ ] Testing Complete
  - [ ] Sandbox purchase works
  - [ ] Premium features unlock
  - [ ] Restore purchases works
  - [ ] Customer Center opens
  - [ ] Subscription cancellation works

---

## Support

**RevenueCat Documentation**: https://www.revenuecat.com/docs/

**Flutter SDK**: https://www.revenuecat.com/docs/getting-started/installation/flutter

**Community**: https://community.revenuecat.com/

**Dashboard**: https://app.revenuecat.com/
