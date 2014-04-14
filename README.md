# cf-apps

A crappy app to display the orgs, spaces, apps and urls in your cf installation in a tree structure.

## Running locally

```

$ git clone https://github.com/simonjohansson/cf-apps.git
$ cd cf-apps
$ rvm use 1.9.3@cfapps --create
$ bundle install
$ export CF_API_URL=http://api.domain.com
$ export CF_ADMIN_USER=admin
$ export CF_ADMIN_PASSWORD=password
$ shotgun
 

```

## Running in CF

```

$ git clone https://github.com/simonjohansson/cf-apps.git
$ cf push
$ cf set-env cf-apps CF_API_URL http://api.domain.com
$ cf set-env cf-apps CF_ADMIN_USER admin
$ cf set-env cf-apps CF_ADMIN_PASSWORD password
$ cf restart

```
