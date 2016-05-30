[![Build Status](https://secure.travis-ci.org/moviepilot/zuck.png?branch=master)](https://travis-ci.org/moviepilot/zuck)

This gem is up for adoption
===========================
Unfortunately, we don't maintain this gem anymore - let [@jayniz](/jayniz) know if you'd like to take over.


Zuck; use facebook's advertisement API with ruby
================

This is a little gem that makes access to facebook's
ads API a little easier. Check out facebook's
[documentation](https://developers.facebook.com/docs/reference/ads-api/)
for a nice diagram that explains how things work.

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

Writing
--------

```ruby
# Directly defining the creative as JSON
creative = '{"type":25,"action_spec":{"action.type":"like", "post":10150420410887685}}'

# Options for the ad group we want to create
o = { bid_type:  1,
      max_bid:   1,
      name:      "My first ad group",
      targeting: '{"geo_locations": {"countries":["US"]}}',
      creative:  creative}

# Create it in the context of my_campaign
group = my_campaign.create_ad_group(o)
=> #<Zuck::AdGroup ad_id: 6005851390151, ad_id: 6005851390151, adset_id: 6005851032951, name: "My first ad group", adgroup_status: 4, bid_type: 1, max_bid: "1", bid_info: {"1":"1"}, ad_status: 4, account_id: "10150585630710217", id: "6005851390151", creative_ids: [6005851371551], targeting: {"geo_locations": {"countries":["US"]},"friends_of_connections":[{"id":"6005851366351","name":null}]}, conversion_specs: [{"action.type":"like","post":"10150420410887685"}], start_time: null, end_time: null, updated_time: 1343916568, created_time: 1343916568>

# Shoot, that was the wrong name
group.name = "My serious ad group"
group.save
=> true

# No wait, let's not spend money on facebook
group.destroy
=> true

# What does destroy mean? Changing the status!
group.ad_status
=> 3
```

AdInterest convenience methods
--------

```ruby
graph = Zuck.graph

# Search for interests (to auto complete, for example) (yes, facebook sometimes returns ids as string and sometimes as numbers)
Zuck::AdInterest.search(graph, "Auto")
=>  [
      {:interest=>"Auto", :id=>"6003156165433", :audience=>nil},
      {:interest=>"#Automobile", :id=>6003176678152, :audience=>97900000},
      {:interest=>"#Auto racing", :id=>6003146718552, :audience=>21800000},
      {:interest=>"#Auto mechanic", :id=>6003109384433, :audience=>14600000}
    ]

# Quickly check if a interest is valid
Zuck::AdInterest.validate(graph, '#Eminem')
=> {"#Eminem" => true}

# Quickly check a couple of interests
Zuck::AdInterest.validate(graph, ['#Eminem', 'Wil Ferel', 'Bronson'])
=> {"#Eminem"=>true, "Bronson"=>true, "Wil Ferel"=>false}

# Make a best guess on how a interest is called on Facebook
Zuck::AdInterest.best_guess(graph, 'Disney')
=> {:interest=>"#The Walt Disney Company", :id=>6003270522085, :audience=>72500000}

# Sometimes a best guess does not return a interest with a # prefix, and that
# means that we don't know the audience of that interest:
Zuck::AdInterest.best_guess(graph, 'Moviepilot')
=> {:interest=>"Moviepilot", :id=>6003327847780, :audience=>nil}

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
  <tr><td style="text-align: right">Ad account group</td> <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>
  <tr><td style="text-align: right">Ad campaign</td>      <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>✔</td></tr>
  <tr><td style="text-align: right">Ad creative</td>      <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>-</td></tr>
  <tr><td style="text-align: right">Ad group</td>         <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>✔</td></tr>
  <tr><td style="text-align: right">Ad set</td>         <td>✔</td><td>✔</td><td>✔</td><td>✔</td><td>✔</td></tr>
  <tr><td style="text-align: right">Ad user</td>          <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td></tr>
</table>

(*) This means if you can, for example, create a new ad group by calling
`my_campaign.create_ad_group(data)` or not.

Users don't exist as objects yet, but you can list all ad users of
an account via `my_ad_account.users` and you will get an array of hashes.

Running tests with your account
-------------------------------

Ensure you have an ad account and a billing method set (you get an error without). Then you are ready to
run the tests and make sure you check your account manager that nothing has been left over.

To-Do
-----

Add convenience stuff, right now everything is quite raw and directly
sent over to facebook. Also, more tests directly to the api with a test
user. Consolidate and test create code with other objects than AdGroup.
