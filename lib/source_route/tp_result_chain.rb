module SourceRoute

  class TpResultChain
    attr_reader :chain

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
        matched_return_tp = return_chain.
          reject { |c| c[:matched] }.  # matched return tp should not checked again
          detect do |rtp|
          rtp[:tp_self] == ctp[:tp_self] and rtp[:method_id] == ctp[:method_id] and rtp[:defined_class] == ctp[:defined_class]
        end
        unless matched_return_tp.nil?
          matched_return_tp[:matched] = true
          ctp[:return_value] = matched_return_tp[:return_value]
          ctp[:local_var] = matched_return_tp[:local_var] if matched_return_tp.key? :local_var
          ctp[:instance_var] = matched_return_tp[:instance_var] if matched_return_tp.key? :instance_var
        end
      end
    end

    def treeize_call_chain
      init_order_id_and_parent_ids
      call_chain.each do |tpr|
        return_tpr = return_chain.find do |rtpr|
          rtpr[:defined_class] == tpr[:defined_class] and rtpr[:method_id] == tpr[:method_id]
        end
        unless return_tpr.nil?
          start_index, end_index = tpr[:order_id], return_tpr[:order_id]
          unless end_index == start_index + 1
            values_at(start_index+1 ... end_index).select { |tpr| tpr[:event] == :call }.each do |tpr|
              tpr[:parent_ids].push start_index
            end
          end
        end
      end

      cal_parent_length
    end

    def parent_length_list
      call_chain.map { |tp| tp[:parent_length] }.uniq.sort
    end

    def deep_cloned
      chain.map { |r| r.clone }
    end

    def stringify
      deep_cloned.map do |tr|
        # to_s is safer than inspect
        # ex: inspect on ActiveRecord_Relation may crash
        tr[:defined_class] = tr[:defined_class].to_s if tr.key?(:defined_class)
        if tr.key?(:return_value)
          if tr[:return_value].nil? or tr[:return_value] == '' or tr[:return_value].is_a? Symbol
            tr[:return_value] = tr[:return_value].inspect
          else
            tr[:return_value] = tr[:return_value].to_s
          end
        end
        tr
      end
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
