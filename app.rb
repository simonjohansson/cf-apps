require 'rubygems'
require 'cfoundry'
require 'cli'
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
      :urls => app.urls.map { |url| ['http://', url].join ''},
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

def get_cf_client(api_url, username, password)
  client = CFoundry::Client.get(api_url)
  client.login({:username => username, :password => password})
  client
end

def get_bosh_client(api_url, user, password)
 Bosh::Cli::Client::Director.new(api_url, user, password)
end

def get_bosh_vm_data(client, deployment)
  client.fetch_vm_state(deployment).sort_by {|vm| vm["job_name"]}
end

get '/' do
  @cf_data = create_data_dict(get_cf_client(ENV['CF_API_URL'], ENV['CF_ADMIN_USER'], ENV['CF_ADMIN_PASSWORD']))
  @vm_data = get_bosh_vm_data(get_bosh_client(ENV['BOSH_API_URL'], ENV['BOSH_ADMIN_USER'], ENV['BOSH_ADMIN_PASSWORD']), ENV['BOSH_DEPLOYMENT'])
  haml :index
end

get '/style.css' do
  scss :style
end
