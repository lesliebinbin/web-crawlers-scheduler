require 'space/json-rpc-app'
Rails.application.routes.draw do
  resources :batch_jobs
  resources :spiders
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount SyncApp, at: '/json-rpc'
end
