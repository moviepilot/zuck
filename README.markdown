[Facebook Marketing API Docs](https://developers.facebook.com/docs/reference/ads-api/)

#### Objects

- Business
- Account
- Campaign
- Ad Set
- Ad
- Ad Creative (Only via API)
- Ad Image (Only via API)

#### Associations

- Business has many Accounts.
- Account has many Campaigns.
- Campaign has many Ad Sets.
- Ad Set has many Ads.
- Ad has one Ad Creative (API only).
- Ad Creative has many Ad Images (API only).

#### Object Details

A Campaign has a particular objective:
- Website conversions OR
- App installs.

An Ad Set has an audience, budget, and schedule.
- For Android app installs we require the following:
  * OS Version 4.0+
  * Android Smartphones (all) + Android Tablets (all)
  * All mobile users
- For iOS app installs we require the following:

An Ad can have two formats:
- A single image.
- Multiple images (carousel).
- For mobile app installs an ad has the following:
  * Images (The minimum dimensions are 600x600)
  * Headline (Example: "Up To 80% Off")
  * Text (Example: "Lowest Prices + Free Shipping on select items.")
  * CTA ("Install Now" is the default)

#### Tophatter User Attribution

- source (Which ad network did the user come from? - "Facebook Ads", "Google" - This is event.media_source in AppsFlyer)
- ad_group (Which specific ad did the user come from? - "Tops", "Watches" - This is event.fb_adgroup_name in AppsFlyer)
- ad_campaign (Which specific ad set did the user come from? - "" - This is event.fb_adset_name in AppsFlyer)
- ad_category # Not used yet.
- ad_product_id # Not used yet.

#### Usage - Ads Management

```
ad_account = Zuck::AdAccount.find(1051938118182807)
campaigns = ad_account.campaigns
```

#### Usage - Audience Management

TBD

#### Usage - Ads Insights

TBD
