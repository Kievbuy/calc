require "sinatra"
require "sinatra/reloader" if development?
require "pry" if development? || test?

set currencies: [{ code: 'UAH', title: 'гривні' }, { code: 'EUR', title: 'євро' }, { code: 'USD', title: 'доллари США' }]

get '/' do
	erb :index
end

post '/' do
  binding.pry
  @params = params.to_s
  erb :index
end