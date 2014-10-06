module Zuck
  require "digest/md5"
  class CustomAudience < RawFbObject

    # The [fb docs](https://developers.facebook.com/docs/reference/ads-api/adaccount/)
    # were incomplete, so I added here what the graph explorer
    # actually returned.
    known_keys :id,
               :name,
               :type,
               :subtype,
               :rule,
               :description,
               :opt_out_link,
               :retention_days


    parent_object :ad_account
    list_path     :customaudiences


    def add_emails(emails)
      audience = emails.map{|email|
        Digest::SHA256.hexdigest(email)
      }
      add_users(audience, "EMAIL_SHA256")
    end

    def add_users(data, schema)
      create_connection(graph, 
                        self.id, 
                        :users, 
                        {payload: {data: data, schema: schema}.to_json}
                       )
    end

  end
end
