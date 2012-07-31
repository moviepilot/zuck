# An object that includes {Zuck::HashDelegator} for easy hash
# access and default keys as methods as well as the `graph`
# getter and setter from {Zuck::Koala::Methods}
module Zuck
  class FbObject
    include Zuck::HashDelegator
    include Zuck::Koala::Methods
  end
end
