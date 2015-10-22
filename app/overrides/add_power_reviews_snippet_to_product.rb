Deface::Override.new(:virtual_path => 'spree/products/show',
  :name => 'add_power_reviews_snippet_to_product',
  :insert_before => "div[data-hook='product_title']",
  :partial => "spree/shared/powerreviews_product_snippet")
