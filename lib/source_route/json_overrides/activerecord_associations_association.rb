if defined? ActiveRecord
  module ActiveRecord
    module Associations
      class Association
        # dump association can trigger ActiveSupport::JSON::Encoding::CircularReferenceError when use rails ~> 4.0.1
        # I try other json gems to fix it, but all failed. That's why I override it here.
        def to_json(options = nil)
          Oj.dump(to_s)
        end
      end
    end

    class Relation

      # Override original method.
      # becasue it trigger SystemStackError: stack level too deep when use rails ~> 4.1.0
      # def as_json(options = nil) #:nodoc:
      #   binding.pry
      #   Json.dump(inspect)
      # end

    end

    class Base
      def source_route_display
        to_s
      end

      # dump association can trigger ActiveSupport::JSON::Encoding::CircularReferenceError when use rails ~> 4.0.1
      # I try other json gems to fix it, but all failed. That's why I override it here.
      #
      # it can affect the json output of rails AR. Not good solution
      # def to_json(options = nil)
      #   JSON.dump(to_s)
      # end
    end # END Base

  end # END ActiveRecord
end
