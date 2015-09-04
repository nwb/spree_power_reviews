Deface::Override.new(:virtual_path => 'spree/home/_product',
  :name => 'add_power_reviews_snippet_to_product_list',
  :insert_after => "span[data-hook='product-title']",
  :partial => "spree/shared/powerreviews_product_snippet")