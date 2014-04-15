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

get '/' do
  @cf_data = create_data_dict(get_cf_client())
  #@data = [{:name=>"system_domain", :spaces=>[]}, {:name=>"casper", :spaces=>[{:name=>"dev", :apps=>[{:name=>"casper-dash", :urls=>["casper-dash.cf1.test.i.springer.com", "cd.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(2/2)"}, {:name=>"trackdash", :urls=>["trackdash.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"83b9723f95b35961a430af269876dc29", :urls=>["env.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"myfirstcfapp", :urls=>["myfirstcfapp.cf1.test.i.springer.com"], :healthy=>false, :instance_count=>"(0/?)"}, {:name=>"48a26f6ba20f0075cc3d39e95ffde69c", :urls=>["env.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"92242dd4f1fc53ae597809baeb0d3210", :urls=>["env.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"springer-token-service", :urls=>["springer-token-service.cf1.test.i.springer.com", "chris-token-service.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"content-api", :urls=>["chris-token-service.cf1.test.i.springer.com"], :healthy=>false, :instance_count=>"(0/?)"}, {:name=>"user-business-partners-service", :urls=>["user-business-partners-service.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"springer-user-service", :urls=>["springer-user-service.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"hipkeeper", :urls=>["hipkeeper.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}, {:name=>"cf-env-hector", :urls=>["cf-env-hector.cf1.test.i.springer.com"], :healthy=>false, :instance_count=>"(0/?)"}, {:name=>"trackanalog", :urls=>["trackanalog.cf1.test.i.springer.com"], :healthy=>false, :instance_count=>"(0/?)"}, {:name=>"asdf", :urls=>["asdf.cf1.test.i.springer.com"], :healthy=>false, :instance_count=>"(0/?)"}, {:name=>"cf-apps", :urls=>["cf-apps.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(2/2)"}]}, {:name=>"live", :apps=>[{:name=>"content-api", :urls=>["content-api-live.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}]}, {:name=>"staging", :apps=>[{:name=>"content-api", :urls=>["content-api-staging.cf1.test.i.springer.com"], :healthy=>false, :instance_count=>"(0/?)"}]}]}, {:name=>"cats-org", :spaces=>[{:name=>"cats-space", :apps=>[]}, {:name=>"persistent-space", :apps=>[{:name=>"persistent-app", :urls=>["persistent-app.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}]}]}, {:name=>"nemo", :spaces=>[{:name=>"dev", :apps=>[{:name=>"tincan-preview-int", :urls=>["tincan-preview-int.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}]}]}, {:name=>"sprcom", :spaces=>[{:name=>"dev", :apps=>[{:name=>"sprcom-price-service", :urls=>["prices.cf1.test.i.springer.com"], :healthy=>true, :instance_count=>"(1/1)"}]}]}]
  @cf_data = create_data_dict(get_cf_client(ENV['CF_API_URL'], ENV['CF_ADMIN_USER'], ENV['CF_ADMIN_PASSWORD']))
  haml :index
end

get '/style.css' do
  scss :style
end
