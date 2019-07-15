module Spree
  module Admin
    class ChannableSettingsController < ResourceController
      def index
        path = model_class.last ? edit_admin_channable_setting_path(model_class.last.id) : new_admin_channable_setting_path
        redirect_to path
      end

      def model_class
        @model_class ||= ::ChannableSetting
      end
    end
  end
end
