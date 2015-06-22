Spree::ProductsController.class_eval do

  before_action :load_product, only: [:review, :question, :answer]

  def review

  end

  def question

  end

  def answer
    render "spree/products/review"
  end

end