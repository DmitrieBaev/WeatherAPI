# bundle exec rspec spec/jobs/store_weather_historical_job_spec.rb

# require 'rails_helper'
#
# # before(:each) do
# #     Delayed::Worker.delay_jobs = false
# # end
#
# describe 'Обновляем текщую погоду каждые 2 часа' do
#     it 'проверям очередь' do
#         # expect(Delayed::Job.count).to eq 0
#         StoreWeatherJob.new.acquire_current
#         # expect(Delayed::Job.count).to eq 1
#         expect(Delayed::Worker.new.work_off).to eq [1, 0]
#     end
# end
