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

AdAccounts
----------

    > Zuck.graph = Koala::Facebook::API.new('my_access_token')
    > accounts = Zuck::AdAccount.all
    > accounts.first
    => #<Zuck::AdAccount id: "act_10150585630710217", account_id: "10150585630710217", name: "", account_status: 1, currency: "USD", timezone_id: 47, timezone_name: "Europe/Berlin", timezone_offset_hours_utc: 2, is_personal: 0, business_name: "Big Mike Alright UG (haftungsbeschr\u00e4nkt)", business_street: "Big Mike Alright UG (haftungsbeschr\u00e4nkt)", business_street2: "J\u00e4gerndorfer Zeile 61", business_city: "Berlin", business_state: "Berlin", business_zip: "12209", business_country_code: "DE", vat_status: 3, daily_spend_limit: 25000, users: [{"uid":501730216,"permissions":[1,2,3,4,5,7],"role":1001}], notification_settings: {"501730216":{"1000":{"1":1},"1001":{"1":1},"1002":{"1":1,"2":60},"1003":{"1":1,"2":60},"1004":{"1":1},"1005":{"1":1},"1006":{"1":1},"1009":{"1":1},"1010":{"1":1},"1011":{"1":1},"2000":{"1":1,"2":60},"2001":{"1":1,"2":60},"2002":{"2":60},"2003":{"1":1,"2":60},"2004":{"1":1,"2":60},"2005":{"1":1,"2":60},"3000":{"1":1,"2":60},"3001":{"1":1,"2":60},"3002":{"2":60},"3003":{"1":1,"2":60},"5000":{"1":1},"6000":{"1":1},"6001":{"1":1},"9000":{"1":1,"2":60},"8000":{"1":1,"2":60}}}, capabilities: [], balance: 0, moo_default_conversion_bid: 1000, moo_default_bid: 1000> 
     > x.currency
    => "USD"    

Campaigns
---------

    c  = FbAds::Campaign.find(my_fb_id)
    c2 = FbAds::Campaign.find_or_create(my_fb_id)

