if defined? ActiveSupport
  # make it respond to to_s. In rails source, almost all of its methods are removed, including to_s.
  module ActiveSupport
    class OptionMerger
      def to_s
        "<#ActiveSupport #{__id__}>"
      end
    end
  end # END ActiveSupport
end
