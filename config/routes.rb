Rails.application.routes.draw do
    mount Edstein::WeatherAPI => '/'
    mount Edstein::HealthAPI => '/'
end
