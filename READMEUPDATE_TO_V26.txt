Due to v2.6 on Facebook API, most of the calles (like ad_campaigns, ad_groups, etc) became invalid.
This small fix helps to solve only some issues. Here is the list of the changed request phrases so far

v2.4 field--v2.5 field
adcampaign_groups--campaigns
adcampaigngroupsbylabels--campaignsbylabels
adcampaigns--adsets
adcampaignsbylabels--adsetsbylabels

adgroups--ads
adgroupsbylabels--adsbylabels
adgroup_review_feedback--ad_review_feedback
adgroup_status--status
adgroup_id--ad_id
adgroup_name--ad_name
campaign_group_status--status
asyncadgrouprequestsets--asyncadrequestsets

campaign_group_id--campaign_id
campaign_schedule--adset_schedule

campaign_id--adset_id
campaign_group_id--campaign_id


The whole complete list is located here:
https://developers.facebook.com/docs/marketing-api/reference/v2.5_rename/v2.6
Again, in thos commit not all the phrases were changed.

Also, after calling 
Zuck.graph = (token, secret)
it is NECESSARY to specify which api version is called by koala as fallowing:
Koala.config.api_version = "v2.6"
Otherwise, the error is raised.
