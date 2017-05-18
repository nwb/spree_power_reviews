Spree::ProductsController.class_eval do

  #before_action :load_product, only: [:question, :answer]

  def review
    @product=Spree::Product.friendly.find(params[:id])
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
    if %w(1807).include?(@product.id.to_s)
      @review_product=Spree::Product.find(1796)
    end
  end

  def question
    @product=Spree::Product.friendly.find(params[:id])
  end

  def answer
    @product=Spree::Product.friendly.find(params[:id])
    render "spree/products/review"
  end

end