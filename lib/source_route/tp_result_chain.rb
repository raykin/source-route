module SourceRoute
  # delegate to Array
  class TpResultChain
    attr_reader :chain

    extend Forwardable
    def_delegators :@chain, :each, :index, :first, :last, :size, :push, :values_at, :pop, :[]

    include Enumerable

    def initialize
      @chain = []
    end

    def call_chain
      select(&:call_event?)
    end

    def return_chain
      select(&:return_event?)
    end

    def import_return_value_to_call_chain
      call_chain.each do |ctp|
        matched_return_tp = return_chain.reject(&:matched?).detect {|rtp| rtp == ctp}
        unless matched_return_tp.nil?
          matched_return_tp.return_tp_assign_call_tp(ctp)
        end
      end
    end

    def treeize_call_chain
      init_order_id_and_parent_ids
      call_chain.each do |tpr|
        # find the return trace point for the call trace point
        return_tpr = return_chain.reject(&:locate_opposite?).find { |rtpr| rtpr == tpr }
        # so trace points between the call trace point and its return trace point
        # are all children of it
        unless return_tpr.nil?
          return_tpr.found_opposite
          start_index, end_index = tpr.order_id, return_tpr.order_id
          unless end_index == start_index + 1
            values_at(start_index+1 ... end_index).select(&:call_event?).each do |ct|
              ct.parent_ids.push start_index
              tpr.direct_child_order_ids.push ct.order_id
            end
          end
        end
      end

      cal_parent_length
    end

    # seems not used in html template now 2015.9.17
    def parent_length_list
      call_chain.map { |tp| tp.parent_length }.uniq.sort
    end

    # def deep_cloned
    #   chain.map { |r| r.clone }
    # end

    # def stringify
    #   deep_cloned.map do |tr|
    #     # to_s is safer than inspect
    #     # ex: inspect on ActiveRecord_Relation may crash
    #     # should moved to tr object
    #     tr.stringify
    #     tr
    #   end
    # end

    private
    def init_order_id_and_parent_ids
      each_with_index do |tpr, index|
        tpr.order_id, tpr.parent_ids, tpr.direct_child_order_ids = index, [], []
      end
    end

    def cal_parent_length
      each do |tpr|
        tpr.parent_length = tpr.parent_ids.length
      end
    end

  end # END TpResultChain
end
