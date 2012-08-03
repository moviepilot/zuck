Zuck; use facebook's advertisement API with ruby
================

This is a little gem that makes access to facebook's 
ads API a little easier. Check out facebook's
[documentation](https://developers.facebook.com/docs/reference/ads-api/)
for a nice diagram that explains how things work.

![](https://dl.dropbox.com/u/1953503/kw29_koelner_gelierzucker_31_oder_diamant_feinster_zucker_462982.jpeg)

Usage
=====

Not everything is supported yet. Here's what you can do currently.


Reading
--------
```ruby
# Let's set a default graph object with an access token
Zuck.graph = Koala::Facebook::API.new('my_access_token')

# Fetching all ad accounts associated to that user
accounts = Zuck::AdAccount.all

# Let's look at an account
my_account = accounts.first
=> #<Zuck::AdAccount id: "act_10150585630710217", account_id: "10150585630710217", name: "", account_status: 1, currency: "USD", timezone_id: 47, timezone_name: "Europe/Berlin", timezone_offset_hours_utc: 2, is_personal: 0, business_name: "Big Mike Alright UG (haftungsbeschr\u00e4nkt)", business_street: "Big Mike Alright UG (haftungsbeschr\u00e4nkt)", business_street2: "J\u00e4gerndorfer Zeile 61", business_city: "Berlin", business_state: "Berlin", business_zip: "12209", business_country_code: "DE", vat_status: 3, daily_spend_limit: 25000, users: [{"uid":501730216,"permissions":[1,2,3,4,5,7],"role":1001}], notification_settings: {"501730216":{"1000":{"1":1},"1001":{"1":1},"1002":{"1":1,"2":60},"1003":{"1":1,"2":60},"1004":{"1":1},"1005":{"1":1},"1006":{"1":1},"1009":{"1":1},"1010":{"1":1},"1011":{"1":1},"2000":{"1":1,"2":60},"2001":{"1":1,"2":60},"2002":{"2":60},"2003":{"1":1,"2":60},"2004":{"1":1,"2":60},"2005":{"1":1,"2":60},"3000":{"1":1,"2":60},"3001":{"1":1,"2":60},"3002":{"2":60},"3003":{"1":1,"2":60},"5000":{"1":1},"6000":{"1":1},"6001":{"1":1},"9000":{"1":1,"2":60},"8000":{"1":1,"2":60}}}, capabilities: [], balance: 0, moo_default_conversion_bid: 1000, moo_default_bid: 1000> 

# Aha. How do I access properties? The documented properties
# have getters:
my_account.currency
=> "USD"    

# But facebook also returns some non documented stuff
my_account[:moo_default_bid]
=> 1000

# Let's fetch the campaigns for this account
my_campaign = my_account.ad_campaigns.first

# Aha! Does this campaign have ad groups?
my_group = my_campaign.ad_groups.first
my_group.name
=> "Group names are silly"

# That was surprising. Just like the fact that ad groups
# have ad creatives associated to them:
my_creative = my_group.ad_creatives.first

# Let's go back up to the parent
my_creative.ad_group.name
=> "Group names are silly"
```

Creating
--------

```ruby
# Directly defining the creative as JSON
creative = '{"type":25,"action_spec":{"action.type":"like", "post":10150420410887685}}'

# Options for the ad group we want to create
o = { bid_type:  1,
      max_bid:   1,
      name:      "My first ad group",
      targeting: '{"countries":["US"]}',
      creative:  creative}
      
# Create it in the context of my_campaign
group = Zuck::AdGroup.create(graph, o, my_campaign)
=> #<Zuck::AdGroup adgroup_id: 6005851390151, ad_id: 6005851390151, campaign_id: 6005851032951, name: "My first ad group", adgroup_status: 4, bid_type: 1, max_bid: "1", bid_info: {"1":"1"}, ad_status: 4, account_id: "10150585630710217", id: "6005851390151", creative_ids: [6005851371551], targeting: {"countries":["US"],"friends_of_connections":[{"id":"6005851366351","name":null}]}, conversion_specs: [{"action.type":"like","post":"10150420410887685"}], start_time: null, end_time: null, updated_time: 1343916568, created_time: 1343916568>
```

Supported objects
-----------------

This gem supports basic CRUD on the objects of the facebook ads api.
Here's a support chart:

<table>
  <tr>
    <th style="text-align:right">Object</th>
    <th style="text-align:center">.all</th>
    <th style="text-align:center">.create</th>
    <th style="text-align:center">.save</th>
    <th style="text-align:center">.destroy</th>
    <th style="text-align:center">parent.create_obj*</th>
  </tr>
  <tr><td style="text-align: right">Ad account</td>       <td>✔</td><td>-</td><td>✔</td><td>✔</td><td>-</td></tr>
  <tr><td style="text-align: right">Ad account group</td> <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>✔</td></tr>
  <tr><td style="text-align: right">Ad campaign</td>      <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>✔</td></tr>
  <tr><td style="text-align: right">Ad creative</td>      <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>✔</td></tr>
  <tr><td style="text-align: right">Ad group</td>         <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>✔</td></tr>
  <tr><td style="text-align: right">Ad image</td>         <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>
  <tr><td style="text-align: right">Ad user</td>          <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>
</table>

(*) This means that you can, for example, create a new ad group by calling
`my_campaign.create_ad_group(data)` or not.

This gem doesn't know anything about `AdUser` yet, and `AdImage` are
not their own objects - they merely exist inside an `AdCreative`.
