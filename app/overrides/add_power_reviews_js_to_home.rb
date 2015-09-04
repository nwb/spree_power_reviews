Deface::Override.new(:virtual_path => 'spree/home/_topselling_products',
  :name => 'add_power_reviews_js_to_home',
  :insert_before => "div[data-hook='homepage_products']",
  :partial => "spree/shared/powerreviews_engine_js")
