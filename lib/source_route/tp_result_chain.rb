module SourceRoute

  class TpResultChain
    extend Forwardable
    def_delegators :@chain, :each, :index, :first, :last, :size, :push, :values_at, :pop, :[]

    include Enumerable

    def initialize
      @chain = []
    end

    def call_chain
      select { |tpr| tpr[:event] == :call }
    end

    def return_chain
      select { |tpr| tpr[:event] == :return }
    end

    def import_return_value_to_call_chain
      call_chain.each do |ctp|
        matched_return_tp = return_chain.detect do |rtp|
          rtp[:tp_self] == ctp[:tp_self] and rtp[:method_id] == ctp[:method_id] and rtp[:defined_class] == ctp[:defined_class]
        end
        ctp[:return_value] = matched_return_tp[:return_value]
        ctp[:local_var] = matched_return_tp[:local_var] if matched_return_tp.key? :local_var
        ctp[:instance_var] = matched_return_tp[:instance_var] if matched_return_tp.key? :instance_var
      end
    end

    def order_call_chain
      init_order_id_and_parent_ids
      call_chain.each do |tpr|
        return_tpr = return_chain.find do |rtpr|
          rtpr[:defined_class] == tpr[:defined_class] and rtpr[:method_id] == tpr[:method_id]
        end

        start_index, end_index = tpr[:order_id], return_tpr[:order_id]
        unless end_index == start_index + 1
          values_at(start_index+1 ... end_index).select { |tpr| tpr[:event] == :call }.each do |tpr|
            tpr[:parent_ids].push start_index
          end
        end
      end

      cal_parent_length
    end

    private
    def init_order_id_and_parent_ids
      each_with_index do |tpr, index|
        tpr[:order_id], tpr[:parent_ids] = index, []
      end
    end

    def cal_parent_length
      each do |tpr|
        tpr[:parent_length] = tpr[:parent_ids].length
      end
    end

  end # END TpResultChain
end
