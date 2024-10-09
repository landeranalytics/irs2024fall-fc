
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





