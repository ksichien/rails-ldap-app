Rails.application.routes.draw do
  devise_for :users, skip: %i[passwords registrations]
  root 'static_pages#home'

  get  'add_groups',    to: 'ldap_users#add'
  post 'add_groups',    to: 'ldap_users#add_groups'
  get  'copy_groups',   to: 'ldap_users#copy'
  post 'copy_groups',   to: 'ldap_users#copy_groups'
  get  'create_user',   to: 'ldap_users#new'
  post 'create_user',   to: 'ldap_users#create'
  get  'destroy_user',  to: 'ldap_users#delete'
  post 'destroy_user',  to: 'ldap_users#destroy'
  get  'remove_groups', to: 'ldap_users#remove'
  post 'remove_groups', to: 'ldap_users#remove_groups'
  get  'update_user',   to: 'ldap_users#edit'
  post 'update_user',   to: 'ldap_users#update'

  get  'add_users',     to: 'ldap_groups#add'
  post 'add_users',     to: 'ldap_groups#add_users'
  get  'create_group',  to: 'ldap_groups#new'
  post 'create_group',  to: 'ldap_groups#create'
  get  'destroy_group', to: 'ldap_groups#delete'
  post 'destroy_group', to: 'ldap_groups#destroy'
  get  'remove_users',  to: 'ldap_groups#remove'
  post 'remove_users',  to: 'ldap_groups#remove_users'

  get  'search',        to: 'ldap_searches#search'
  post 'search',        to: 'ldap_searches#search_result'
  get  'search_groups',  to: 'ldap_searches#search_groups'
  post 'search_groups',  to: 'ldap_searches#search_groups_result'
end
