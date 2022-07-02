require 'date'
require 'json'


module Edstein
    # Ростов-на-Дону id => "cityId:295146"

    class WeatherAPI < Grape::API
        prefix :api
        version 'v1'
        format :json

        resource :weather do
            # /api/v1/weather/current
            desc 'Текущая температура'
            get :current do
                AcquireWeatherJob.perform_now if $redis.get("cityId:295146:current").nil?

                status :ok
                JSON.parse $redis.get("cityId:295146:current")
            end

            # /api/v1/weather/by_time
            # http://localhost:3000/api/v1/weather/by_time?timestamp=1391655852
            # http://localhost:3000/api/v1/weather/by_time?timestamp=1621823790
            desc 'Найти температуру ближайшую к переданному timestamp'
            get :by_time do
                _timestamp = params[:timestamp].nil? ? Time.zone.now.strftime("%-m/%-d/%Y") : Time.at(params[:timestamp].to_i).strftime("%-m/%-d/%Y")

                AcquireWeatherForecastJob.perform_now if $redis.get("cityId:295146:forecast").nil?

                data = JSON.parse $redis.get("cityId:295146:forecast")
                _idx = data['forecast_date'].index _timestamp
                if _idx.nil?
                    status :not_found
                    { error: "В архиве нет данных за эту дату" }
                else
                    status :ok
                    { date: _timestamp, temperature: ((data['forecast_daytime_high'][_idx].to_i + data['forecast_daytime_low'][_idx].to_i) / 2).round }
                end
            end

            resource :historical do
                before do
                    @weather_historical = $redis.get "cityId:295146:historical"
                    @error_responce = { error: "На текущий момент нет исторических сведений по погоде за сегодня" }
                end

                # /api/v1/weather/historical
                desc 'Почасовая температура за последние 24 часа'
                get do
                    if @weather_historical.nil?
                        status :not_found
                        @error_responce
                    else
                        status :ok
                        JSON.parse @weather_historical
                    end
                end

                # /api/v1/weather/historical/max
                desc 'Максимальная температура за последние 24 часа'
                get :max do
                    if @weather_historical.nil?
                        status :not_found
                        @error_responce
                    else
                        status :ok
                        data = JSON.parse(@weather_historical).map{ |_, value| value.to_i }
                        _, max = data.minmax
                        { historical_max: max }
                    end
                end

                # /api/v1/weather/historical/min
                desc 'Минимальная температура за последние 24 часа'
                get :min do
                    if @weather_historical.nil?
                        status :not_found
                        @error_responce
                    else
                        status :ok
                        data = JSON.parse(@weather_historical).map{ |_, value| value.to_i }
                        min, _ = data.minmax
                        { historical_min: min }
                    end
                end

                # /api/v1/weather/historical/avg
                desc 'Средняя температура за последние 24 часа'
                get :avg do
                    if @weather_historical.nil?
                        status :not_found
                        @error_responce
                    else
                        # avg = @weather_historical.map(&:to_i)
                        data = JSON.parse(@weather_historical).map{ |_, value| value.to_i }
                        status :ok
                        { historical_avg: (data.inject(:+).to_f / data.size).round }
                    end
                end
            end  # resource :historical

            resource :forecast do
                # /api/v1/weather/forecast
                desc 'Прогноз на следующие 7 дней'
                get do
                    AcquireWeatherForecastJob.perform_now if $redis.get("cityId:295146:forecast").nil?

                    status :ok
                    JSON.parse $redis.get("cityId:295146:forecast")
                end
            end  # resource :forecast
        end  # resource :weather
    end  # class WeatherAPI

    class HealthAPI < Grape::API
        prefix :api
        version 'v1'
        format :json

        resources :health do
            # /api/v1/health
            desc 'Статус бекенда'
            get do
                status :ok
                { health: :ok  }
            end
        end
    end
end
