2.2.0
=====

- fixed support for API version 2.4 (2.2 is no longer officially supported)
- removed deprecated api attributes and added new ones
- fixed tests to work with one single account and access token

2.1.0
=====

- added creating and saving ad-creatives
- disabled view_tags in AdGroup (needs App whitelisting to work)
- fixed invalid attributes due to deprecation in Facebook Ad API version 2.2
- updated specs and tapes 
- implemented automatic setup and removal of test data (creative, ad set, campaign)

2.0.0
=====

- update Koala to 1.10.1
- use the `/search?type=adinterestq=interest` endpoint to validate ad interests
  instead of `/search?type=adinterestvalid&interest_list=['interest']`
- use json objects instead of string values for ad interests
- don't escape commas with %2C when passing searches on to koala
- update ad account properties
- fix consecutive `#save`s without a `#reload` in between 

Breaking changes:
----------------

If you upgrade from 1.x, make sure you read the following:

- `Zuck::AdInterest.search` results use the `audience_size` key in order to use
  the same names as the facebook api. In zuck 1.x it was `audience`
- `Zuck::TargetingSpec`
  - `initialize` does not take string interests anymore,
    but expects `{id: '123', name: 'foo'} objects, see
    "[Specifying values for interests as a string will be sunset in favor of a JSON object of id and name](https://developers.facebook.com/docs/apps/migrations/ads-api-changes-2014-04-09)"
  - in your targeting spec, don't specify `{countries: ['US']}`, but
    `{geo_locations: { countries: ['US']}}`
- `Zuck::AdInterest.best_guess` returns an ad interest object, what was
  formerly the `:interest` key is now called `:name`
- Ad Campaigns are now called Ad Sets, and Ad Sets can be grouped
  together in Ad Campaigns [see docs](https://developers.facebook.com/docs/reference/ads-api/adcampaign/v2.2)


1.0.0
=====
- Implement Facebook's April 9 breaking changes, which also change this
  gem
- AdKeyword/keywords are gone, welcome AdInterest/interests
  (see [the
docs](https://developers.facebook.com/docs/reference/ads-api/interest-targeting))
- locations became geo_locations, and you can now also target cities
  (see [the
docs](https://developers.facebook.com/docs/reference/ads-api/targeting-specs))

0.2.0
=====
- implement Facebook's [Oct 2013 breaking changes](https://developers.facebook.com/roadmap/#q4_2013)

0.0.9
=====
- add Zuck::TargetingSpec.valid_countries? method to allow for country
  validation from the outside

0.0.8
=====
- validate the countries before fetching a reach estimate

0.0.7
-----
- don't downcase keywords when normalizing, it matters for keywords
  with a # as a prefix

0.0.4
=====
- integrated targeting spec to fetch reach estimates
