Deface::Override.new(
  virtual_path: 'spree/admin/stores/_form',
  name: 'add_faire_api_key_to_stores',
  insert_bottom: '[data-hook="admin_store_form_fields"]',
  partial: 'spree/admin/stores/faire_api_key'
)
