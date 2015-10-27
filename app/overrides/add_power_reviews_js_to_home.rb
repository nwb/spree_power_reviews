Deface::Override.new(:virtual_path => 'spree/home/index',
  :name => 'add_power_reviews_js_to_home',
  :insert_before => "div[data-hook='home_content']",
  :partial => "spree/shared/powerreviews_engine_js")
