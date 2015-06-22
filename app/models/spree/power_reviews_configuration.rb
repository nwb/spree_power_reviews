module Spree
  class PowerReviewsConfiguration

    def self.account
      power_reviews_yml=File.join(Rails.root,'config/power_reviews.yml')
      if File.exist? power_reviews_yml
        power_reviews_yml=File.join(Rails.root,'config/power_reviews.yml')
        YAML.load(File.read(power_reviews_yml))
      end
    end
  end
end