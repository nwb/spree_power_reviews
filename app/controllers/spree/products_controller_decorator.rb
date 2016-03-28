Spree::ProductsController.class_eval do

  before_action :load_product, only: [:review, :question, :answer]

  def review
    @review_product=@product
    if %w(1738 1739 1740).include?(@product.id.to_s)
      @review_product=Spree::Product.find(1737)
    end
    #fo-ti
    if %w(1770).include?(@product.id.to_s)
      @review_product=Spree::Product.find(1439)
    end
    #ksg
    if %w(1839).include?(@product.id.to_s)
      @review_product=Spree::Product.find(1077)
    end
  end

  def question

  end

  def answer
    render "spree/products/review"
  end

end