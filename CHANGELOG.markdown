1.0.0
-----
- Implement Facebook's April 9 breaking changes, which also change this
  gem
- AdKeyword/keywords are gone, welcome AdInterest/interests
  (see [the
docs](https://developers.facebook.com/docs/reference/ads-api/interest-targeting))
- locations became geo_locations, and you can now also target cities
  (see [the
docs](https://developers.facebook.com/docs/reference/ads-api/targeting-specs))

0.2.0
-----
- implement Facebook's [Oct 2013 breaking changes](https://developers.facebook.com/roadmap/#q4_2013)

0.0.9
-----
- add Zuck::TargetingSpec.valid_countries? method to allow for country
  validation from the outside

0.0.8
-----
- validate the countries before fetching a reach estimate

0.0.7
-----
- don't downcase keywords when normalizing, it matters for keywords
  with a # as a prefix

0.0.4
-----
- integrated targeting spec to fetch reach estimates
