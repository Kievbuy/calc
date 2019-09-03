require "sinatra"
require 'json'
require 'date'
require "sinatra/reloader" if development?
require "pry" if development? || test?

set currencies: [{ code: 'UAH', title: 'гривні' }, { code: 'EUR', title: 'євро' }, { code: 'USD', title: 'доллари США' }]
set time_ranges: [{ code: 'none', title: 'немає' }, { code: 'monthly', title: 'щомісячно' }, { code: 'quarterly', title: 'щоквартально' }, { code: 'annually', title: 'щорічно' }]

get '/' do
  @data = nil
	erb :index
end

post '/' do
  # binding.pry
  @params = params
  @data = calculate_deposit(@params)
  erb :index
end

private

def calculate_deposit(raw_data)
  months = raw_data["period_type"] == 'years' ? raw_data['period_value'].to_i * 12 : raw_data['period_value'].to_i
  data = {}
  date = Date.parse(raw_data['date'])
  start_amount = raw_data['deposit'].to_f

  total_days = Integer((date >> months) - date)
  dayly_rate = (10/100.to_f) / 365

  index = 0

  months.times do
    data[index] = {}
    if index.positive?
      days_in_the_month = Integer((date >> 1) - date)
      date = date >> 1
      data[index][:date] = date
      data[index][:days_number] = days_in_the_month
      data[index][:body] = start_amount
      data[index][:income] = start_amount * (dayly_rate * days_in_the_month)
    else
      data[index][:date] = date
      data[index][:body] = start_amount
    end
    index += 1
  end
  data
end