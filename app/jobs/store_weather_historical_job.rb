require 'json'


class StoreWeatherJob
    def acquire_current
        weather_current = Accuweather.get_conditions(location_id: "cityId:295146", metric: true).current
        $redis.set "cityId:295146:current", {
            current_temperature:    weather_current.temperature,
            current_weather:        weather_current.weather_text,
            current_pressure:       weather_current.pressure,
            current_humidity:       weather_current.humidity,
            current_cloud_cover:    weather_current.cloud_cover }.to_json
    end
    handle_asynchronously :acquire_current, :run_at => Proc.new { 2.hours.from_now }

    def acquire_forecast
        weather_forecast = Accuweather.get_conditions(location_id: 'cityId:295146', metric: true).forecast
        $redis.set "cityId:295146:forecast", {
            forecast_date:           weather_forecast.map(&:date),
            forecast_daytime_high:   weather_forecast.map(&:daytime).map(&:high_temperature),
            forecast_daytime_low:    weather_forecast.map(&:daytime).map(&:low_temperature),
            forecast_nighttime_high: weather_forecast.map(&:nighttime).map(&:high_temperature),
            forecast_nighttime_low:  weather_forecast.map(&:nighttime).map(&:low_temperature) }.to_json
    end
    handle_asynchronously :acquire_forecast, :run_at => Proc.new { Date.tomorrow.noon }

    def store_historical
        weather_current = Accuweather.get_conditions(location_id: "cityId:295146", metric: true).current

        if $redis.get("cityId:295146:historical").nil?
            $redis.set "cityId:295146:historical", { Time.zone.now.strftime("%H"): weather_current.temperature }.to_json
        else
            parsed = JSON.parse $redis.get("cityId:295146:historical")
            parsed.merge!(Time.zone.now.strftime("%H"): weather_current.temperature)
            $redis.set "cityId:295146:historical", parsed.to_json
        end
    end
    # Каждый час добавлять сведения о температуре
    handle_asynchronously :store_hourly, :run_at => Proc.new { 1.hours.from_now }

    def clear_historical
        $redis.del('cityId:295146:historical')
    end
    handle_asynchronously :clear_historical, :run_at => Proc.new { Date.tomorrow.noon }
end

background_worker = StoreWeatherJob.new
background_worker.acquire_current
background_worker.acquire_forecast
background_worker.store_historical
background_worker.clear_historical
