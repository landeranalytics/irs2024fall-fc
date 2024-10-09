
data <- c(123, 125, 128, 130, 135, 138, 140, 145)

?ts

ts_data <- ts(data, start = c(2020, 1), frequency = 12)
class(ts_data)
class(data)
start(ts_data)
end(ts_data)
frequency(ts_data)
time(ts_data)

zoo::as.yearmon(time(ts_data))
lubridate::my(zoo::as.yearmon(time(ts_data)))

# annual
ts(data, start = c(2020, 1), frequency = 1) |> print(calendar = T)
ts(data, start = c(2020, 1), frequency = 31)
ts(data, start = c(2020, 1), frequency = 7) |> time()
ts(data, start = c(2020, 1), frequency = 365)
ts(data, start = c(2020, 1), frequency = 365.25)

# piping
#%>%
#|>

mean(rnorm(100))
rnorm(100) |> mean() |> round()

# multivariate
matrix(rnorm(300), 100, 3)
ts(
  matrix(rnorm(300), 100, 3),
  start = c(2020, 1),
  frequency = 12
)

AirPassengers
class(AirPassengers)
plot(AirPassengers)
time(AirPassengers)

data("rock")

AirPassengers



# plotting ----------------------------------------------------------------

AirPassengers

library(forecast)
library(ggplot2)
autoplot(AirPassengers) +
  labs(title = "My title", x = NULL, y = "Count")


autoplot(AirPassengers) +
  scale_x_date()

gg <- autoplot(AirPassengers)
structure(gg)
View(gg)
gg$data


# decomposition -----------------------------------------------------------

AirPassengers

# additive
decomposed <- decompose(AirPassengers, type = "additive")
decomposed
plot(AirPassengers)
plot(decomposed)

# multiplicative
decomposed <- decompose(AirPassengers, type = "multiplicative")
decomposed
plot(decomposed)

# stl
?stl
decomposed <- stl(AirPassengers, s.window = 12)
plot(decomposed)

# s.window
stl(AirPassengers, s.window = 12) |> plot()
stl(AirPassengers, s.window = 25) |> plot()
stl(AirPassengers, s.window = "p") |> plot()
stl(AirPassengers, s.window = "periodic") |> plot()

frequency(co2)
stl(log(co2), s.window = 21) |> plot()
stl(log(co2), s.window = "per") |> plot()

# decomposition using fable
library(forecast)
library(fable)
library(tsibble)
dat_example <- pedestrian |>
  dplyr::filter(Sensor == dplyr::first(Sensor)) |>
  fill_gaps()

dat_example |>
  fabletools::model(tslm = TSLM(Count ~ trend())) |>
  interpolate(dat_example) |>
  model(stl = feasts::STL(Count)) |>
  # model(stl = feasts::STL(Count ~ trend(window = 10))) |>
  components() |>
  autoplot()


# tsibble -----------------------------------------------------------------

library(ggplot2)
library(tsibble)
library(forecast)
library(fable)

data("pedestrian")
pedestrian
dim(pedestrian)
nrow(pedestrian)
ncol(pedestrian)
class(pedestrian)

# plot a panel plot
autoplot(pedestrian, Count) + facet_wrap(~Sensor)


has_gaps(pedestrian)
count_gaps(pedestrian)
scan_gaps(pedestrian)
fill_gaps(pedestrian)

fill_gaps(pedestrian) |> scan_gaps()


pedestrian |>
  scan_gaps() |>
  ggplot(aes(x = Date_Time, y = 1)) +
  geom_col() +
  facet_wrap(~Sensor)


pedestrian_filled <- fill_gaps(pedestrian)

pedestrian_filled |>
  fabletools::model(tslm = TSLM(Count ~ trend())) |>
  interpolate(pedestrian_filled)


pedestrian_int <- pedestrian_filled |>
  fabletools::model(tslm = TSLM(Count ~ trend())) |>
  interpolate(pedestrian_filled)

autoplot(pedestrian, Count) + facet_wrap(~Sensor)
autoplot(pedestrian_int, Count) + facet_wrap(~Sensor)



# modeling - basics -------------------------------------------------------

library(fable)
library(fabletools)


pedestrian_int
rwf


ped_bir <- pedestrian_int |>
  dplyr::filter(Sensor == dplyr::first(Sensor)) |>
  dplyr::filter(
    lubridate::year(Date_Time) == 2015,
    lubridate::month(Date_Time) %in% 1:2
  )

# fit a random walk using forecast
rw_model <- rwf(ped_bir, h = 24)
rw_model
class(rw_model)

plot(rw_model, main = "Random Walk Forecast")

# fit many models using fable
my_models <- pedestrian_int |>
  fabletools::model(
    mean = fable::MEAN(Count),
    naive = fable::NAIVE(Count),
    snaive = fable::SNAIVE(Count)
  )

# this returns a mable
my_models
class(my_models)

plot(my_models)
autoplot(my_models)

# forecast
my_models |>
  forecast(h = 24)

my_models |>
  forecast(h = 24) |>
  autoplot()

# include historical data in our plot
my_models |>
  forecast(h = 24) |>
  autoplot(
    pedestrian_int
  )

# limit historical data
my_models |>
  forecast(h = 24) |>
  autoplot(
    pedestrian_int |> dplyr::filter(Date_Time >= as.Date("2016-12-01"))
  )

my_models |>
  dplyr::select(Sensor, snaive) |>
  forecast(h = 24) |>
  autoplot(
    pedestrian_int |> dplyr::filter(Date_Time >= as.Date("2016-12-01"))
  )

# combination model
my_models |>
  dplyr::mutate(
    comb = (mean + naive) / 2
  ) |>
  dplyr::select(Sensor, comb) |>
  forecast(h = 24) |>
  autoplot(
    pedestrian_int |> dplyr::filter(Date_Time >= as.Date("2016-12-01"))
  )


# model evaluation --------------------------------------------------------

ped_train <- pedestrian_int |>
  dplyr::filter(lubridate::year(Date_Time) == 2015)

ped_test <- pedestrian_int |>
  dplyr::filter(lubridate::year(Date_Time) == 2016)

ped_models <- ped_train |>
  fabletools::model(
    mean = fable:::MEAN(Count),
    naive = fable::NAIVE(Count),
    snaive = fable::SNAIVE(Count)
  )

fc <- fabletools::forecast(ped_models, new_data = ped_test)
ped_metrics <- fabletools::accuracy(fc, ped_test)
View(ped_metrics)

ped_metrics |>
  tibble::as_tibble() |>
  dplyr::group_by(Sensor) |>
  dplyr::summarize(best_model = .model[which.min(RMSE)])

#
# ped_metrics |>
#   dplyr::select(-.type) |>
#   tidyr::pivot_longer(-c('.model', 'Sensor')) |>
#   ggplot(aes(x = value, y = .model)) +
#   geom_col() +
#   facet_wrap(~Sensor)


# cross validation --------------------------------------------------------

pedestrian_int
pedestrian_int |> dplyr::count(Sensor)

ped_stretched <- pedestrian_int |>
  stretch_tsibble(.step = 24*30, .init = 16000)

ped_stretched |>
  dplyr::distinct(Sensor, .id) |>
  View()

# View(ped_stretched)

pedestrian_int |>
  slide_tsibble(.size = 360, .step = 30)

pedestrian_int |>
  tile_tsibble(.size = 360)



# ets and arima -----------------------------------------------------------

range(pedestrian_int$Date_Time)

.step <- 24*30
ped_stretched <- pedestrian_int |>
  dplyr::filter(Date_Time >= as.Date("2016-01-01")) |>
  stretch_tsibble(.step = .step, .init = 800)

ped_stretched <- ped_stretched |>
  dplyr::group_by(.id) |> # BUG HERE: should be group_by(Sensor, .id)
  dplyr::mutate(is_train = Date_Time < max(Date_Time) - .step) |>
  dplyr::ungroup()

table(ped_stretched$is_train)


nrow(dplyr::distinct(ped_stretched, Sensor, .id))

stretched_train <- ped_stretched |>
  dplyr::filter(is_train)
stretched_test <- ped_stretched |>
  dplyr::filter(!is_train)

# train the models
ped_models <- stretched_train |>
  fabletools::model(
    snaive = fable::SNAIVE(Count),
    ets = fable::ETS(Count),
    ets = fable::ETS(Count ~ error() + trend() + season()),
    arima = fable::ARIMA(Count ~ trend() + season())
    # ets = fable::ETS(Count ~ error() + trend('A') + season('M'))
  )

# make forecasts
ped_fc <- ped_models |>
  fabletools::forecast(new_data = stretched_test)

# check metrics
ped_fc |>
  fabletools::accuracy(stretched_test)

#
ped_fc |>
  fabletools::accuracy(stretched_test, by = c(".model", "Sensor"))

# visualize
ped_fc |>
  fabletools::accuracy(stretched_test, by = c(".model", "Sensor"))


# EXERCISE

library(forecast)
library(fable)
library(fabletools)
library(tsibble)
library(ggplot2)

pedestrian_filled <- fill_gaps(pedestrian)

pedestrian_int <- pedestrian_filled |>
  fabletools::model(tslm = TSLM(Count ~ trend())) |>
  interpolate(pedestrian_filled)

ped_daily <- pedestrian |>
  group_by_key() |>
  tsibble::index_by(Date) |>
  dplyr::summarize(n = sum(Count))

# fill missing values
ped_daily <- ped_daily |>
  fill_gaps() |>
  model(TSLM(n)) |>
  interpolate(fill_gaps(ped_daily))

# plot it
autoplot(ped_daily) + facet_wrap(~Sensor)

.step <- 30
range(ped_daily$Date)
stretched <- ped_daily |>
  # dplyr::mutate(exo_1 = rnorm(2877)) |>
  stretch_tsibble(.step = .step, .init = 600) |>
  dplyr::group_by(Sensor, .id) |>
  dplyr::mutate(is_train = Date < max(Date) - .step) |>
  dplyr::ungroup()

table(stretched$is_train)

stretched |>
  # dplyr::filter(Sensor == "Southern Cross Station") |>
  ggplot(aes(x = Date, y = n, color = is_train)) +
  geom_line() +
  facet_grid(Sensor~.id, scales = "free_y")

stretched_train <- stretched |>
  dplyr::filter(is_train)
stretched_test <- stretched |>
  dplyr::filter(!is_train)

#### Train
ped_models <- stretched_train |>
  model(
    ets = fable::ETS(n ~ error() + trend() + season()),
    arima = fable::ARIMA(n ~ trend() + season())
  )

nrow(ped_models)
stretched |> dplyr::distinct(Sensor, .id) |> nrow()


# make forecasts
ped_fc <- ped_models |>
  fabletools::forecast(new_data = stretched_test)

# evaluate
ped_fc |> fabletools::accuracy(stretched_test)
ped_fc |> fabletools::accuracy(stretched_test, by = c('Sensor', '.model'))
ped_fc |>
  fabletools::accuracy(stretched_test, by = c('Sensor', '.model')) |>
  ggplot(aes(x = RMSE, y = .model)) +
  geom_col() +
  facet_wrap(~Sensor)




# exogenous ---------------------------------------------------------------

# incomplete example data
.data <- tibble::tibble(
  n = rnorm(10),
  temperature = rnorm(10),
  is_lockdown = rbinom(n = 10, size = 1, prob = c(0.5, 0.5))
)

# estimate lambda
lambda <- pedestrian_int |>
  fabletools::features(Count, feasts::guerrero) |>
  dplyr::pull(lambda_guerrero) |>
  mean()

# example modeling
# .data |>
#   fabletools::model(
#     mean = MEAN(box_cox(n, lambda)),
#     naive = NAIVE(box_cox(n, lambda)),
#     snaive = fable::SNAIVE(fabletools::box_cox(n, lambda)),
#     drift = fable::RW(fabletools::box_cox(n, lambda) ~ drift()),
#     ets = fable::ETS(fabletools::box_cox(n, lambda) ~ trend() + season()),
#     arima = fable::ARIMA(fabletools::box_cox(n, lambda) ~ temperature + rain + snow + wind_speed + is_lockdown + is_covid + is_holiday + is_workday + n_workers),
#     nnts = NNETAR(box_cox(n, lambda) ~ temperature + rain + snow + wind_speed + is_lockdown + is_covid + is_holiday + is_workday + n_workers),
#     prophet = fable.prophet::prophet(fabletools::box_cox(n, lambda) ~ temperature + rain + snow + wind_speed + is_lockdown + is_covid + is_holiday + is_workday + n_workers +
#                                        growth('linear') +
#                                        season('week', type = 'additive') +
#                                        season('year', type = 'additive'))
#   )


