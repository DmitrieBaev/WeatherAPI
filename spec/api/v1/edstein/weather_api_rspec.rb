# bundle exec rspec spec/api/v1/edstein/weather_api_rspec.rb

require 'rails_helper'


describe 'Тестируем маршрут получения текущей погоды', type: :request do
    before { get '/api/v1/weather/current' }

    it 'возвращает статус код 200' do
        expect(response).to have_http_status(:success)
    end

    it 'имеет правильную структуру' do
        expect(JSON.parse(response.body)).to include 'current_temperature'
        expect(JSON.parse(response.body)).to include 'current_weather'
        expect(JSON.parse(response.body)).to include 'current_pressure'
        expect(JSON.parse(response.body)).to include 'current_humidity'
        expect(JSON.parse(response.body)).to include 'current_cloud_cover'
    end
end

describe 'Тестируем маршрут получения погоды по timestamp', type: :request do

    it 'при обращение без передачи параметра возвращает по текущей дате' do
        get '/api/v1/weather/by_time'
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['date']).to eq(Time.zone.now.strftime("%-m/%-d/%Y"))
    end

    it 'при обращении с передачей не существующего timestamp возвращает 404 с ожидаемым текстом сообщения' do
        get '/api/v1/weather/by_time?timestamp=1391655852'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('В архиве нет данных за эту дату')
    end

    it 'при обращение с передачей существущего timestamp возвращает по текущей дате' do
        get "/api/v1/weather/by_time?timestamp=#{ (Time.now + 1.day).to_i }"
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['date']).to eq(Time.zone.tomorrow.strftime("%-m/%-d/%Y"))
    end
end

describe 'Тестируем маршруты получения погоды за 24 часа с отсутствующими историческими данными', type: :request do
    before { $redis.del 'cityId:295146:historical' }

    it 'при обращение к полной истории (за 24 часа)' do
        get '/api/v1/weather/historical'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('На текущий момент нет исторических сведений по погоде за сегодня')
    end

    it 'при обращение для получения максимальной температуры за 24 часа' do
        get '/api/v1/weather/historical/max'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('На текущий момент нет исторических сведений по погоде за сегодня')
    end

    it 'при обращение для получения минимальной температуры за 24 часа' do
        get '/api/v1/weather/historical/min'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('На текущий момент нет исторических сведений по погоде за сегодня')
    end

    it 'при обращение для получения средней температуры за 24 часа' do
        get '/api/v1/weather/historical/avg'
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('На текущий момент нет исторических сведений по погоде за сегодня')
    end
end

describe 'Тестируем маршруты получения погоды за 24 часа с присутствующими историческими данными', type: :request do
    before { $redis.set 'cityId:295146:historical', {"12": "33", "13": "32", "14": "35"}.to_json }

    it 'при обращение к полной истории (за 24 часа)' do
        get '/api/v1/weather/historical'
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq(JSON.parse({"12": "33", "13": "32", "14": "35"}.to_json))
    end

    it 'при обращение для получения максимальной температуры за 24 часа' do
        get '/api/v1/weather/historical/max'
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['historical_max']).to eq(35)
    end

    it 'при обращение для получения минимальной температуры за 24 часа' do
        get '/api/v1/weather/historical/min'
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['historical_min']).to eq(32)
    end

    it 'при обращение для получения средней температуры за 24 часа' do
        get '/api/v1/weather/historical/avg'
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['historical_avg']).to eq(33)
    end
end

describe 'Тестируем маршруты получения прогноза погоды на 7 дней', type: :request do
    before do
        weather_forecast = Accuweather.get_conditions(location_id: 'cityId:295146', metric: true).forecast
        $redis.set "cityId:295146:forecast", {
            forecast_date:           weather_forecast.map(&:date),
            forecast_daytime_high:   weather_forecast.map(&:daytime).map(&:high_temperature),
            forecast_daytime_low:    weather_forecast.map(&:daytime).map(&:low_temperature),
            forecast_nighttime_high: weather_forecast.map(&:nighttime).map(&:high_temperature),
            forecast_nighttime_low:  weather_forecast.map(&:nighttime).map(&:low_temperature) }.to_json
    end

    it 'получаем корректные данные' do
        get '/api/v1/weather/forecast'
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq(JSON.parse($redis.get "cityId:295146:forecast"))
    end
end

describe 'Тестируем статуса бекенда', type: :request do

    it 'получаем корректные данные' do
        get '/api/v1/health'
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['health']).to eq("ok")
    end
end
