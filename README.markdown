Facebook Ads gem
================

This is a little gem that makes access to facebook's 
ads API a little easier. Check out facebook's
[documentation](https://developers.facebook.com/docs/reference/ads-api/)
for a nice diagram that explains how things work.

Usage
=====

Not everything is supported, here's what's implemented
so far.

Campaigns
---------

    c  = FbAds::Campaign.find(my_fb_id)
    c2 = FbAds::Campaign.find_or_create(my_fb_id)

