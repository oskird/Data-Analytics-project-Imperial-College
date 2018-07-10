library(readr)
library(readxl)
library(xts)
library(lubridate)
library(dplyr)

# Changes in Spot Rate
FX_spot <- read_excel("E:/oskird/course/10. Big Data in Finance/assignment/group assignment 2/FX.xlsx",
                      sheet = 1)
Date <- FX_spot$Date
Date <- ymd(paste0(substr(Date, 1,4),'-', substr(Date, 5,6), '-01'))
FX_spot <- xts(x=as.matrix(FX_spot[-1]), order.by = Date)
FX_spot_mod <- diff(log(FX_spot))
FX_spot_mod <- as.data.frame(FX_spot_mod)
FX_spot_mod$Date <- Date
FX_spot_mod <- select(FX_spot_mod, 10, 1:9)
write_csv(as.data.frame(FX_spot_mod), 'modified_data.xlsx')

# Interest Differential 
EuroDep <- read_excel("E:/oskird/course/10. Big Data in Finance/assignment/group assignment 2/FX.xlsx",
sheet = 2)
usd <- EuroDep$USD
EuroDep_mod <- EuroDep - usd
EuroDep_mod$Date <- Date
EuroDep_mod <- select(EuroDep_mod, 1:10)
write_csv(EuroDep_mod, 'Interest Differential.csv')

# Inflation Differential
cpi <- read_excel("E:/oskird/course/10. Big Data in Finance/assignment/group assignment 2/FX.xlsx",
                          sheet = 5)
cpi <- xts(x=as.matrix(cpi[-1]), order.by = Date)
cpi_mod <- diff(log(cpi))
cpi_mod <- as.data.frame(cpi_mod)
cpi_mod$Date <- Date
usd <- cpi_mod$USD
cpi_mod <- cpi_mod-usd
cpi_mod <- cpi_mod %>% select(11, 1:9)
write_csv(cpi_mod, 'Inflation Differential.csv')

# IP Differential 
IndProduction <- read_excel("E:/oskird/course/10. Big Data in Finance/assignment/group assignment 2/FX.xlsx",
                          sheet = 4)
IndProduction <- log(IndProduction)
usd <- IndProduction$USD
IndProduction_mod <- (IndProduction - usd) %>% select(1:9)
IndProduction_mod$Date <- Date
write_csv(IndProduction_mod, 'IP Differential.csv')

# MS Differential
MoneySupply <- read_excel("E:/oskird/course/10. Big Data in Finance/assignment/group assignment 2/FX.xlsx",
                            sheet = 3)
MoneySupply <- log(MoneySupply)
usd <- MoneySupply$USD
MoneySupply_mod <- (MoneySupply - usd) %>% select(1:9)
MoneySupply_mod$Date <- Date
# write_csv(MoneySupply_mod, 'MS Differential.csv')