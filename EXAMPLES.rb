# Accounts
accounts = Zuck::AdAccount.all
account = Zuck::AdAccount.find('act_1051938118182807')
account = Zuck::AdAccount.find_by(name: 'Web')

# Campaigns
account = Zuck::AdAccount.find_by(name: 'Web')
campaigns = account.campaigns(effective_status: ['ACTIVE'])
campaign = Zuck::Campaign.find('6071826205057')
campaign.ad_account

# Ad Sets
ad_sets = Zuck::Campaign.find('6071826205057').ad_sets
ad_set = Zuck::AdSet.find('6071827548857')
ad_set.campaign

# Ads
ads = Zuck::AdSet.find('6071827548857').ads
ad = Zuck::Ad.find('6071827590657')
ad.ad_set
ad.ad_creative

# Ad Creatives
ad_creatives = Zuck::AdAccount.find_by(name: 'Web').ad_creatives
ad_creative = Zuck::AdCreative.find('6071827541257')

# Ad Images
ad_images = Zuck::AdAccount.find_by(name: 'Web').ad_images
ad_image = Zuck::AdAccount.find_by(name: 'Web').ad_images(hashes: ['70af2c94f2fb994b69bd6e32f9acb2f0']).first
