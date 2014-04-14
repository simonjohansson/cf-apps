require 'rubygems'
require 'cfoundry'
require 'sinatra'
require 'haml'
require 'sass'

def create_data_dict(client)
  client.organizations.map { |org|
    {
      :name => org.name,
      :spaces => spaces_in_org(org)
    }
  }
end

def spaces_in_org(org)
  org.spaces.map { |space|
    {
      :name => space.name,
      :apps => apps_in_space(space)
    }
  }
end

def apps_in_space(space)
  space.apps.map { |app|
    {
      :name => app.name,
      :urls => app.urls,
      :healthy => app.healthy?,
      :instance_count => app_status(app)
    }
  }
end

def app_status(app)
  if app.healthy?
    instances = app.instances
    num_instances = instances.length
    num_running = instances.select { |i| i.status == "RUNNING" }.length
    "(#{num_running}/#{num_instances})"
  else
    "(0/?)"
  end
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
