if defined? ActiveRecord
  class ActiveRecord::Associations::Association

    # dump association can trigger ActiveSupport::JSON::Encoding::CircularReferenceError when use rails ~> 4.0.1
    # I try other json gems to fix it, but all failed. That's why I override it here.
    def to_json(options = nil)
      JSON.dump(to_s)
    end
  end

  class ActiveRecord::Base

    # dump association can trigger ActiveSupport::JSON::Encoding::CircularReferenceError when use rails ~> 4.0.1
    # I try other json gems to fix it, but all failed. That's why I override it here.
    #
    # it can affect the json output of rails AR. Not good solution
    # def to_json(options = nil)
    #   JSON.dump(to_s)
    # end
  end

end
