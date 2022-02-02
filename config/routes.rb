Rails.application.routes.draw do
  # get 'sessions/new'
  # get 'users/new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # get '/login', to: 'static_pages#login'
  # get '/signup', to: 'static_pages#signup'
  # get '/login' => 'login#new'
  get    '/login'  => 'sessions#new'
  post   '/login'  => 'sessions#create'
  delete '/logout' => 'sessions#destroy'
  # get '/signup' => 'signup#new'
  get '/signup' => 'users#new'
  post '/signup' => 'users#create'
  resources :users
  root 'static_pages#index'
  # root 'home#index'
  get '/dashboard' => 'dashboard#index'
  # get     'trials'          => 'trials#index'
  # get     'trials/new'      => 'trials#new'
  # post    'trials'          => 'trials#create'
  # delete  'trials/:id' => 'trials#destroy'
  # get     'trials/:id/edit' => 'trials#edit'
  # patch   'trials/:id'      => 'trials#update'
  # get     'trials/:id'      => 'trials#show'

  resources 'trials'
  get '/static_pages'   => 'static_pages#index'
  get '/static_pages2' => 'static_pages2#index'
  get '/static_pages/tasks' => 'static_pages#tasks'
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  get '/admin/'           =>  'admin#index'
  get '/admin/login'      =>  'admin/sessions#new'
  post '/admin/login'     => 'admin/sessions#create'
  delete '/admin/logout'  => 'admin/sessions#destroy'
  namespace :admin do
    resources :users
    resources :managers
    resources :login, only: [:new]
  end

  namespace :api, format: 'json' do
    resources :tasks, only: [:index, :create, :update]
    resources :users, only: [:show]
    resources :projects, only: [:index, :create, :update, :show, :destroy]
    resources :boards, only: [:index, :create, :update, :show, :destroy]
    # get '/static_pages'   => 'static_pages#index'
  end
  get '/dashboard/' => 'dashboard#index'
  get '/dashboard/mystation' => 'dashboard#index'
  get '/dashboard/projects/:id' => 'dashboard#index'
  get '/dashboard/boards/:id' => 'dashboard#index'
end
