Deface::Override.new(:virtual_path => 'spree/products/show',
  :name => 'add_qa_to_product',
  :insert_after => "div[data-hook='product_directions']",
  :partial => "spree/shared/powerreviews_product_qas")
