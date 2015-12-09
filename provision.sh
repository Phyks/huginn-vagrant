#!/bin/bash

apt-get update
apt-get install -y vim mc screen # not needed, I just prefer to have them around.
update-alternatives --set editor /usr/bin/vim.basic

# Install the required packages (needed to compile Ruby and native extensions to Ruby gems):
sudo apt-get install -y runit build-essential git zlib1g-dev libyaml-dev libssl-dev libgdbm-dev \
  libreadline-dev libncurses5-dev libffi-dev curl openssh-server checkinstall libxml2-dev libxslt-dev \
  libcurl4-openssl-dev libicu-dev logrotate python-docutils pkg-config cmake nodejs graphviz

# Remove the old Ruby versions if present:
apt-get remove -y ruby1.8 ruby1.9

# Download Ruby and compile it:
mkdir /usr/src/ruby && cd /usr/src/ruby
curl -L  http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.bz2 | tar xj
cd ruby-2.2.3
./configure --disable-install-rdoc
make -j`nproc`
make install

# Install the bundler and foreman gems:
gem install bundler foreman --no-ri --no-rdoc

# Create a user for Huginn:
adduser --disabled-login --gecos 'Huginn' huginn

# Install the database packages:
# FIXME (next two lines)
debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootmysqlpassword'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootmysqlpassword'
apt-get install -y mysql-server-5.5 mysql-server mysql-client libmysqlclient-dev

# Set up MySQL user
# FIXME: Next line, use the same as DATABASE_USERNAME and DATABASE_PASSWORD from the env file
mysql -u root -prootmysqlpassword <<< "CREATE USER 'huginn'@'localhost' IDENTIFIED BY 'mysqlpassword';"
# FIXME: Next two lines, use the same as 'rootmysqlpassword' above
mysql -u root -prootmysqlpassword <<< "SET storage_engine=INNODB;"
mysql -u root -prootmysqlpassword <<< "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES ON huginn_production.* TO 'huginn'@'localhost';"

# Clone the Source
cd /home/huginn
sudo -u huginn -H git clone https://github.com/cantino/huginn.git -b master huginn
cd /home/huginn/huginn
sudo -u huginn mkdir -p log tmp/pids tmp/sockets
chown -R huginn log/ tmp/
chmod -R u+rwX,go-w log/ tmp/
chmod -R u+rwX,go-w log/
chmod -R u+rwX tmp/
sudo -u huginn -H cp config/unicorn.rb.example config/unicorn.rb

# Copy .env file into place
sudo -u huginn  cp /vagrant/env /home/huginn/huginn/.env
sudo -u huginn -H chmod o-rwx .env

# Install the Gems
sudo -u huginn -H bundle install --deployment --without development test

# Create the database
sudo -u huginn -H bundle exec rake db:create RAILS_ENV=production

# Migrate to the latest version
sudo -u huginn -H bundle exec rake db:migrate RAILS_ENV=production

# Create admin user and example agents
sudo -u huginn -H bundle exec rake db:seed RAILS_ENV=production

# Compile Assets
sudo -u huginn -H bundle exec rake assets:precompile RAILS_ENV=production

# Copy Procfile into place
sudo -u huginn  cp /vagrant/Procfile /home/huginn/huginn/Procfile

# Export the init scripts:
rake production:export

# Setup Logrotate
cp deployment/logrotate/huginn /etc/logrotate.d/huginn

# Check it's running
rake production:status

# Install nginx
apt-get install -y nginx
cp deployment/nginx/huginn /etc/nginx/sites-available/huginn
ln -s /etc/nginx/sites-available/huginn /etc/nginx/sites-enabled/huginn
cp /vagrant/huginn /etc/nginx/sites-available/huginn
rm /etc/nginx/sites-enabled/default
nginx -t
service nginx restart





















