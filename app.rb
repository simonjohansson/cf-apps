require 'rubygems'
require 'cfoundry'
require 'sinatra'
require 'haml'
require 'sass'

def create_data_dict(client)
  Hash[client.organizations.map { |org| [org.name, spaces_in_org(org)] }]
end

def spaces_in_org(org)
  Hash[org.spaces.map { |space| [space.name, apps_in_space(space)] }]
end

def apps_in_space(space)
  Hash[space.apps.map { |app| [app.name, urls_bound_to_app(app)] }]
end

def urls_bound_to_app(app)
  app.urls
end

def get_connection
  client = CFoundry::Client.get(ENV['CF_API_URL'])
  client.login({:username => ENV['CF_ADMIN_USER'], :password => ENV['CF_ADMIN_PASSWORD']})
  client
end

get '/' do
  @data = create_data_dict(get_connection())
  haml :index
end

get '/style.css' do
  scss :style
end