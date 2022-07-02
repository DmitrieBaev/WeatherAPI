class AcquireWeatherForecastJob < ApplicationJob
    self.queue_adapter = :resque
    queue_as :default

    def perform(*args)
        weather_forecast = Accuweather.get_conditions(location_id: 'cityId:295146', metric: true).forecast
        $redis.set "cityId:295146:forecast", {
            forecast_date:              weather_forecast.map(&:date),
            forecast_daytime_high:      weather_forecast.map(&:daytime).map(&:high_temperature),
            forecast_daytime_low:       weather_forecast.map(&:daytime).map(&:low_temperature),
            forecast_nighttime_high:    weather_forecast.map(&:nighttime).map(&:high_temperature),
            forecast_nighttime_low:     weather_forecast.map(&:nighttime).map(&:low_temperature) }.to_json
    end
end
