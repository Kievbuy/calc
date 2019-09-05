require File.expand_path '../spec_helper.rb', __FILE__
require 'pry'

describe "My Sinatra Calc App" do
  it "should allow accessing the home page" do
    get '/'

    expect(last_response).to be_ok
    expect(last_response.body).to include('Депозитний калькулятор')
  end

  it "should return calculation result" do
    post '/', {"currency"=>"UAH",
               "deposit"=>"1000.00",
               "annual_rate"=>"10.00",
               "date"=>"2019-09-05",
               "period_type"=>"years",
               "period_value"=>"1",
               "capitalisation"=>"none"}

    expect(last_response).to be_ok
  end
end
