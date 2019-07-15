Deface::Override.new(
  virtual_path: "spree/admin/shared/sub_menu/_configuration",
  name: "add_channable_settings_configuration_menu",
  insert_bottom: '[data-hook="admin_configurations_sidebar_menu"]',
  text: '<%= configurations_sidebar_menu_item "Channable settings", spree.admin_channable_settings_path %>'
)

shipping_method_form = <<-ERB

    <div data-hook="admin_shipping_method_form_channable_name" class="col-md-2">
      <%= f.field_container :channable_channel_name, :class => ['form-group'] do %>
        <%= f.label :channable_channel_name, Spree.t(:channable_channel_name) + '(s)' %>
        <%= f.text_field :channable_channel_name, class: 'form-control', label: false %>
        <%= f.error_message_on :channable_channel_name %>
      <% end %>
    </div>

    <div data-hook="admin_shipping_method_form_channable_transporter_code" class="col-md-2">
      <%= f.field_container :channable_transporter_code, :class => ['form-group'] do %>
        <%= f.label :channable_transporter_code, Spree.t(:channable_transporter_code) %>
        <%= f.text_field :channable_transporter_code, class: 'form-control', label: false %>
        <%= f.error_message_on :channable_transporter_code %>
      <% end %>
    </div>
ERB

Deface::Override.new(
    virtual_path: "spree/admin/shipping_methods/_form",
    name: "add_channable_settings_to_shipping_methods",
    insert_after: '[data-hook="admin_shipping_method_form_tracking_url_field"]',
    text: shipping_method_form
)