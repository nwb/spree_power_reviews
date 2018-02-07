class CreateSpreeReviewSet < SpreeExtension::Migration[4.2]
  def self.up
    create_table :spree_review_sets do |t|
      t.column :inline_path, :string
      t.column :full_review_count, :int
      t.column :average_rating, :decimal
      t.column :bottom_line_yes_votes, :int
      t.column :bottom_line_no_votes, :int
      t.column :qa_inline_path, :string
    end
    change_table :spree_products do |t|
      t.references :review_set
    end
  end

  def self.down
    drop_table :spree_review_sets
  end
end
