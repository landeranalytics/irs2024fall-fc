
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





