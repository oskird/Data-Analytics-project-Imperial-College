library(readxl)
library(rpart)
library(rpart.plot)
data <- read_excel("ind.xlsx")

control = rpart.control(minsplit=0, maxdepth = 30) 
model <- rpart(traffic~day+weather+time, data, control=control)
rpart.plot(model)
pred <- predict(model, data, type="class")

entropy <- function(weight, prob1, prob2){
  return(-(weight*(prob1*log2(prob1) + (1-prob1)*log2(1-prob1))+(1-weight)*(prob2*log2(prob2) + (1-prob2)*log2(1-prob2))))
}
#1 ig_weather
en_total <- entropy(1, 0.44, 0.99)
en_weather <- entropy(0.72, 0.28, 0.86)
ig_weather <- en_total - en_weather
en_day <- entropy(0.2, 0.8, 0.35)
ig_day <- en_total - en_day
en_time <- entropy(0.48, 5/12, 6/13)
ig_time <- en_total - en_time

#2 ig_wea_day1
en_weather_1 <- -0.72*(0.28*log2(0.28)+0.72*log2(0.72))
en_weather_2 <- -0.28*(0.86*log2(0.86)+0.14*log2(0.14))
ig_wea_day1 <- en_weather_1 - (-0.6*(0.13*log2(0.13)+0.87*log2(0.87)))
ig_wea_time1 <- en_weather_1 - entropy(0.72*0.5, 1/3, 2/9)
ig_wea_day2 <- en_weather_2 - (-0.08*(0.5*log2(0.5)*2))
ig_wea_time2 <- en_weather_2 - (-3/7*(1/3*log2(1/3)+2/3*log2(2/3)))

#3 ig_wea_day2
en_weather_day <- (-0.6*(0.13*log2(0.13)+0.87*log2(0.87)))
ig_3_day <- en_weather_day - (-0.32*(0.25*log2(0.25)+0.75*log2(0.75)))

#4 ig_wea_day_time2
en_wea_day_time2 <- -0.08*(2*0.5*log2(0.5))
ig_wea_day_time2 <- en_wea_day_time2

#5 ig_3_day
