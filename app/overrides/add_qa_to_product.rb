Deface::Override.new(:virtual_path => 'spree/products/show',
  :name => 'add_qa_to_product',
  :insert_before => "div[data-hook='description']",
  :partial => "spree/shared/powerreviews_product_qas")
