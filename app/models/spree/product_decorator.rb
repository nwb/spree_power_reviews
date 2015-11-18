Spree::Product.class_eval do
    belongs_to :review_set
    delegate :inline_path, :qa_inline_path, :full_review_count, :average_rating, :bottom_line_yes_votes, :bottom_line_no_votes, :to => :review_set, :prefix => true, :allow_nil => true

end