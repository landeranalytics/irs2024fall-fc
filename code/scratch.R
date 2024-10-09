
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
decomposed <- stl(AirPassengers, s.window = 12) # investigate
plot(decomposed)

# s.window
stl(AirPassengers, s.window = 12) |> plot()
stl(AirPassengers, s.window = 12) |> plot()
stl(AirPassengers, s.window = 30) |> plot()
stl(AirPassengers, s.window = 365) |> plot()
stl(AirPassengers, s.window = "periodic") |> plot()

# decomposition using fable
dat_example <- pedestrian |>
  dplyr::filter(Sensor == dplyr::first(Sensor)) |>
  fill_gaps()

dat_example |>
  fabletools::model(tslm = TSLM(Count ~ trend())) |>
  interpolate(dat_example) |>
  model(stl = feasts::STL(Count)) |>
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




