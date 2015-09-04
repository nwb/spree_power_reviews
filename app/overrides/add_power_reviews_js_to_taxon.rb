Deface::Override.new(:virtual_path => 'spree/taxons/show',
  :name => 'add_power_reviews_js_to_home',
  :insert_before => "div[data-hook='taxon_products']",
  :partial => "spree/shared/powerreviews_engine_js")
