module Halibut

  module DSL

    def instance_eval_with_previous_context_available(*args, &block)
      DslDelegator.new(self).instance_eval_with_previous_context_available(&block)
    end

    class DslDelegator

      def initialize delegation_target
        @delegation_target = delegation_target
      end

      def instance_eval_with_previous_context_available(*args, &block)
        with_previous_context_available(block.binding) do
          bind_block_as_instance_method_on_self(&block).call(*args)
        end
      end

      protected

      def method_missing(method, *args, &block)
        if delegation_target_responds_to? method
          delegation_target.send(method, *args, &block)
        else
          previous_context.send(method, *args, &block)
        end
      end

      private

      attr_accessor :delegation_target, :previous_context

      def bind_block_as_instance_method_on_self(&block)
        create_instance_method_from_block(&block).bind(self)
      end

      def create_instance_method_from_block &block
        meth = self.class.class_eval do
          define_method :___block_as_instance_method_, &block
          meth = instance_method :___block_as_instance_method_
          remove_method :___block_as_instance_method_
          meth
        end
      end

      def with_previous_context_available(binding, &block)
        @previous_context = binding.eval('self')
        result = block.call
        @previous_context = nil
        result
      end

      def delegation_target_responds_to?(method)
        delegation_target.respond_to? method
      end

    end
  end
end