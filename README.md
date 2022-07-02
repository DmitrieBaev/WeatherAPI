# API для статистики по погоде.

Ендпоинты:
* /api/v1/weather/current
* /api/v1/weather/forecast
* /api/v1/weather/historical
* /api/v1/weather/historical/max
* /api/v1/weather/historical/min
* /api/v1/weather/historical/avg
* /api/v1/weather/by_time?timestamp=
* /api/v1/health

Требований к хранению данных не предъявлено, поэтому проект был создан без ActiveRecord, а в качестве локального хранилища использовался Redis.

API разработан с помощью Grape.

RSpec-тестами покрыты два job`ера и ендпоинты API.
