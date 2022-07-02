# bundle exec rspec spec/jobs/acquire_weather_forecast_job_spec.rb

require 'rails_helper'

RSpec.describe AcquireWeatherForecastJob, type: :job do
    describe "#perfome_later" do
        before { $redis.del "cityId:295146:forecast" }

        it 'заполняем значения прогнозом погоды на 7 дней' do
            ActiveJob::Base.queue_adapter = :test
            expect {
                AcquireWeatherForecastJob.set(wait_until: 1.seconds.from_now, queue: "low").perform_later
            }.to have_enqueued_job.on_queue("low").at(1.seconds.from_now)
        end
    end
end
