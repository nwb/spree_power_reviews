Spree::Core::Engine.add_routes do
  # Add your extension routes here
  resources :products do
    member do
      get 'review'
      get 'question'
      get 'answer'
    end
  end
end
