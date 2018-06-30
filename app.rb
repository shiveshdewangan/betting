require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:user] ||= {}
end

get '/bet' do
  if session[:user]["current_balance"] <= 0
    redirect '/broke'
  else
    erb :bet
  end
end

post '/bet' do
  user_guess = params[:guess]
  bet_amount = params[:bet]
  random_guess = [1, 2, 3].sample

  if !(1..session[:user]['current_balance']).cover?(bet_amount.to_i)
    session[:message] = "Bets must be between $1 and $#{session[:user]['current_balance']}."
    redirect '/bet'
  else
    if random_guess == user_guess.to_i
      session[:user]['current_balance'] += bet_amount.to_i
      session[:message] = 'You have guessed correctly.'
      redirect '/bet'
    else
      session[:message] = "You guessed #{user_guess}, but the number was #{random_guess}."
      session[:user]['current_balance'] -= bet_amount.to_i
      redirect '/bet'
    end
  end
end

get '/broke' do
  erb :broke
end

get '/' do
  session[:user] = {}
  session[:user]['current_balance'] = 100
  session[:message] = ''
  redirect '/bet'
end
