Rails.application.routes.draw do
  # get 'users/new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # get '/login', to: 'static_pages#login'
  # get '/signup', to: 'static_pages#signup'
  get '/login' => 'login#new'
  # get '/signup' => 'signup#new'
  get '/signup' => 'users#new'
  post '/signup' => 'users#create'
  resources :users
  root 'static_pages#index'
  # get     'trials'          => 'trials#index'
  # get     'trials/new'      => 'trials#new'
  # post    'trials'          => 'trials#create'
  # delete  'trials/:id' => 'trials#destroy'
  # get     'trials/:id/edit' => 'trials#edit'
  # patch   'trials/:id'      => 'trials#update'
  # get     'trials/:id'      => 'trials#show'

  resources 'trials'
  get '/static_pages' => 'static_pages#index'
  get '/static_pages2' => 'static_pages2#index'
  get '/static_pages/tasks' => 'static_pages#tasks'
  get '/admin/login', to: 'admin/login#new'
  namespace :admin do
    resources :users, only: [:index]
    resources :login, only: [:new]
  end
  
end
