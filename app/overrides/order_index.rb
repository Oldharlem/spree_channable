Deface::Override.new(
    virtual_path: 'spree/admin/orders/index',
    name: 'add tradebyte order info header',
    insert_after: '#listing_orders thead th:nth-last-child(3)',
    partial: 'spree/admin/orders/index_channable_state_override_head'
)

Deface::Override.new(
    virtual_path: 'spree/admin/orders/index',
    name: 'add tradebyte order info',
    insert_after: '#listing_orders tbody td:nth-last-child(3)',
    partial: 'spree/admin/orders/index_channable_state_override'
)
