module AbAdmin
  class AbstractResource
    unloadable

    include Singleton

    ACTIONS = [:index, :show, :new, :edit, :create, :update, :destroy, :preview, :batch, :rebuild] unless self.const_defined?(:ACTIONS)

    attr_accessor :table, :search, :export, :form, :preview_path, :actions, :settings, :custom_settings,
                  :batch_action_list, :action_items, :disabled_action_items, :resource_action_items, :tree_node_renderer

    def initialize
      @actions = ACTIONS
      @batch_action_list = [AbAdmin::Config::BatchAction.new(:destroy, :confirm => I18n.t('admin.delete_confirmation'))]
      @action_items = []
      @disabled_action_items = []
      @default_action_items_for = {}
      @action_items_for = {}
    end

    class << self
      def table(options={}, &block)
        instance.table = AbAdmin::Config::Table.new(options, &block)
      end

      def search(options={}, &block)
        instance.search = AbAdmin::Config::Search.new(options, &block)
      end

      def export(options={}, &block)
        instance.export = ::AbAdmin::Config::Export.new(options, &block)
      end

      def form(options={}, &block)
        instance.form = ::AbAdmin::Config::Form.new(options, &block)
      end

      def preview_path(value=nil, &block)
        instance.preview_path = block_given? ? block : value
      end

      def actions(*actions_to_keep)
        instance.actions = begin
          options = actions_to_keep.extract_options!
          if options[:except]
            ACTIONS - Array(options[:except]).map(&:to_sym)
          else
            actions_to_keep
          end
        end.map(&:to_sym)
      end

      def settings(value)
        instance.custom_settings = value
      end

      def batch_action(name, options={}, &block)
        if !options
          instance.batch_action_list.reject!{|a| a.name == name }
        else
          instance.batch_action_list << AbAdmin::Config::BatchAction.new(name, options, &block)
        end
      end

      def action_item(*args, &block)
        options = args.extract_options!
        if block_given?
          instance.action_items << AbAdmin::Config::ActionItem.new(options, &block)
        elsif args[1].is_a?(FalseClass)
          instance.disabled_action_items << args[0]
        end
      end

      def resource_action_items(*actions)
        instance.resource_action_items = actions + instance.resource_action_items.find_all { |a| a.is_a?(AbAdmin::Config::ActionItem) }
      end

      def resource_action_item(options={}, &block)
        instance.resource_action_items << AbAdmin::Config::ActionItem.new(options, &block)
      end

      def tree(&block)
        instance.tree_node_renderer = block
      end
    end

    def allow_action?(action)
      return true unless actions
      actions.include?(action.to_sym)
    end

    def action_items_for(action)
      @action_items_for[action] ||= action_items.find_all{|i| i.for_action?(action) }
    end

    def default_action_items_for(action, for_resource)
      @default_action_items_for[action] ||= begin
        base = [:new]
        base += [:edit, :show, :destroy, :preview] if for_resource
        @actions & (base - @disabled_action_items)
      end
    end

    def resource_action_items
      @resource_action_items ||= [:edit, :show, :destroy, :preview]
    end

  end

end