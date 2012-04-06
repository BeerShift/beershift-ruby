require 'sinatra/base'
require 'httparty'
require 'json'

class BeerShift < Sinatra::Base

  set :views, File.expand_path('../../views', __FILE__)

  get '/' do 	
    
    @beers = Beer.firehose
    erb :index

  end

  get '/user/username/:username' do
    
    halt 400 unless params[:username]

    username = params[:username].downcase
    user = User.where(:username => username).first

    if user
      JSON.dump({ :username => user.username, :password => user.password })
    else
      halt 404
    end

  end

  post '/user' do

    halt 400 unless params[:username]
    halt 400 unless params[:password]

    username = params[:username].downcase

    user = User.create_user(username, params[:password])

    if user
      JSON.dump({ :status => 'success' })
    else
      JSON.dump({ :status => 'failed' })
    end   

  end

  get '/userbeers/username/:username' do

    halt 400 unless params[:username]

    username = params[:username].downcase

    beers = Beer.for_user(username)

    if beers
      response = beers.inject([]) { |list, beer| list << { :username => beer.username, :beer => beer.beer, :when => beer.when } }
      JSON.dump(response)
    else
      halt 404
    end

  end

  get '/firehose' do

    beers = Beer.firehose

    if beers
      response = beers.inject([]) { |list, beer| list << { :username => beer.username, :beer => beer.beer, :when => beer.when } }
      JSON.dump(response)
    else
      halt 404
    end

  end

  get '/beers/name/:name' do

    halt 400 unless params[:name]

    query = {
      :key => 'A1029384756B', 
      :q => params[:name],
      :type => 'beer',
      :withBreweries => 'Y'
    }
    response = HTTParty.post('http://api.playground.brewerydb.com/search/', :query => query)
    parsed = JSON.parse(response.body)

    if parsed['status'] && parsed['status'] == 'success'
      response
    else
      halt 404
    end

  end

  post '/beers' do

    halt 400 unless params[:username]
    halt 400 unless params[:beerName]
    halt 400 unless params[:when]

    username = params[:username].downcase

    beer = Beer.drink(username, params[:beerName], DateTime.strptime(params[:when].gsub(/(\d+)(th|st|nd|rd)/, '\1'), '%B %e, %Y, %l:%M:%S %p'))

    if beer
      JSON.dump({ :status => 'success' })
    else
      JSON.dump({ :status => 'failed' })
    end   

  end

end
