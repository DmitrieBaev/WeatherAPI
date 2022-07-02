class AcquireWeatherJob < ApplicationJob
    self.queue_adapter = :resque
    queue_as :default

    def perform(*args)
        weather_current = Accuweather.get_conditions(location_id: "cityId:295146", metric: true).current
        $redis.set "cityId:295146:current", {
            current_temperature:    weather_current.temperature,
            current_weather:        weather_current.weather_text,
            current_pressure:       weather_current.pressure,
            current_humidity:       weather_current.humidity,
            current_cloud_cover:    weather_current.cloud_cover }.to_json
    end
end
