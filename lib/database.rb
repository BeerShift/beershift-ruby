require 'mongoid'

Mongoid.load!(File.expand_path('../../config/mongoid.yml', __FILE__))

class User
  
  include Mongoid::Document

  field :username, :type => String
  field :password, :type => String

  def self.create_user(username, password)
  	u = self.new
  	u.username = username
  	u.password = password
  	u.save
  end

end

class Beer
  
  include Mongoid::Document

  store_in :drank

  field :username, :type => String
  field :when, :type => DateTime
  field :beer, :type => String

  def self.firehose
  	self.limit(50).order_by([[:when, :desc]]).all
  end

  def self.for_user(username)
  	Beer.where(:username => username).limit(50).order_by([[:when, :desc]]).all
  end

  def self.drink(username, beer, date)
  	b = self.new
  	b.username = username
  	b.beer = beer
  	b.when = date
  	b.save
  end

end