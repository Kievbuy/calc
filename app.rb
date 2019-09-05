require "sinatra"
require 'json'
require 'date'
require "sinatra/reloader" if development?
require "pry" if development? || test?

set currencies: [{ code: 'UAH', title: 'гривні' }, { code: 'EUR', title: 'євро' }, { code: 'USD', title: 'доллари США' }]
set time_ranges: [{ code: 'none', title: 'немає' }, { code: 'monthly', title: 'щомісячно' }, { code: 'quarterly', title: 'щоквартально' }, { code: 'annually', title: 'щорічно' }]

get '/' do
	erb :index
end

post '/' do
  @params = params
  @deposit = params['deposit'].to_f
  @currency = params['currency']
  @data, @total_days, @total_income = calculate_deposit(@params)
  erb :index
end

private
##########################################################

def calculate_deposit(raw_data)
  months = raw_data["period_type"] == 'years' ? raw_data['period_value'].to_i * 12 : raw_data['period_value'].to_i
  data = {}
  date = Date.parse(raw_data['date'])

  current_body = raw_data['deposit'].to_f
  total_income = current_body

  dayly_rate = (raw_data['annual_rate'].to_f/100) / 365

  index = 0

  (months + 1).times do
    data[index] = {}
    if index.positive?
      days_in_the_month = Integer((date >> 1) - date)
      date = date >> 1
      data[index][:date] = date.to_s
      data[index][:days_number] = days_in_the_month

      income = current_body * (dayly_rate * days_in_the_month)
      total_income += income

      data[index][:income] = income

      current_body = calculate_capitalisation(data, current_body, index, total_income, raw_data['capitalisation'])

      data[index][:body] = current_body
    else
      data[index][:date] = date.to_s
      data[index][:body] = current_body
    end
    index += 1
  end
  [data, data.inject(0) { |sum, record| sum += record[1][:days_number].to_i }, total_income]
end

def calculate_capitalisation(data, body, index, total_income, capitalisation)
  case capitalisation
  when 'monthly'
    body + data[index][:income]
  when 'quarterly'
    index % 3 != 0 ? body : total_income
  when 'annually'
    index % 12 != 0 ? body : total_income
  when 'none'
    body
  else
    body
  end
end

