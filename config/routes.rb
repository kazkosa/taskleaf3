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
  get '/app' => 'dashboard#index'
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
    resources :users do
      resources :tasks, only: [:new]
    end
    resources :managers
    resources :workspaces do
      resources :projects, only: [:new]
    end
    resources :projects do
      resources :boards, only: [:new]
    end
    resources :boards do
      resources :states, only: [:new]
      resources :tasks, only: [:new]
    end
    resources :states
    resources :tasks
    resources :login, only: [:new]
  end

  namespace :api, format: 'json' do
    resources :tasks, only: [:index, :create, :update]
    resources :users, only: [:index, :show] do
      collection do
        get :count
      end
    end
    resources :workspaces, only: [:index, :create, :update, :show, :destroy] do
      resources :workspace_members,     only: [:index, :update]
      member do
        put :update_members
        get :search_child_members
      end
      resources :projects, only: [:index ] do
        collection do
          get :index_manager
        end
      end
    end
    resources :workspace_members, only: [:update, :destroy]

    resources :projects, only: [:index, :create, :update, :show, :destroy] do
      resources :project_members,     only: [:index, :update]
      member do
        put :update_members
        get :search_child_members
      end
      resources :boards, only: [:index]
    end
    resources :project_members, only: [:show, :update, :destroy]

    resources :boards, only: [:index, :create, :update, :show, :destroy] do
      resources :board_members,     only: [:index, :update]
      member do
        put :update_members
      end
      resources :states, only: [:index]
    end
    resources :board_members, only: [:show, :update, :destroy] do
      collection do
        get :search
      end
    end
    resources :states, only: [:create, :show, :update, :destroy]

    # get '/static_pages'   => 'static_pages#index'
  end

  get '/app/' => 'dashboard#index'
  get '/app/mystation' => 'dashboard#index'
  get '/app/ws' => 'dashboard#index', as: 'app_workspaces'
  get '/app/ws/:id' => 'dashboard#index', as: 'app_workspace'
  get '/app/ws/:id/members' => 'dashboard#index', as: 'app_workspace_members'
  get '/app/ws/:id/setting' => 'dashboard#index', as: 'app_workspace_setting'
  get '/app/projects' => 'dashboard#index'
  get '/app/projects/:id' => 'dashboard#index', as: 'app_project'
  get '/app/projects/:id/members' => 'dashboard#index', as: 'app_project_members'
  get '/app/projects/:id/setting' => 'dashboard#index', as: 'app_project_setting'
  get '/app/boards/:id' => 'dashboard#index', as: 'app_boards'
  get '/app/boards/:id/members' => 'dashboard#index', as: 'app_board_members'
  get '/app/boards/:id/setting' => 'dashboard#index', as: 'app_board_setting'
end
