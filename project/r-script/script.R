# --------------------------- Section 0: Load packages --------------------------- #
library(LSTS) # for Ljung Box test
library(aTSA) # for Augmented Dickey Fuller test
library(forecast) # forecasting
library(spectral) # for spectral filter

# --------------------------- Section 1: Load data --------------------------- #
# Raw data (with bad quality segments remove)
data.raw = read.csv("final_cleaned_data.csv")

# Constants
NROW = nrow(data.raw)
NCOL = ncol(data.raw)
FIRST_DATE = "1867-12-29"
FORECAST_FIRST_DATE = "1983-12-01"

# --------------------------- Section 2: Remove seasonal component --------------------------- #
# Oscillations to be subtracted
seasonal.annual = spectral::filter.fft(data.raw$MaxTemp, x = NULL, fc = 0.002725, BW = 0.00105, n = 1)
seasonal.biannual = spectral::filter.fft(data.raw$MaxTemp, x = NULL, fc = 0.00545, BW = 0.0002, n = 1)

# This is for recovering original data
imaginary_residuals = Im(data.raw$MaxTemp - seasonal.annual - seasonal.biannual)

# This is for further processing
data.raw.filtered = data.frame(data.raw)
data.raw.filtered$MaxTemp = Re(data.raw$MaxTemp - seasonal.annual - seasonal.biannual)

# --------------------------- Section 3: Normalization --------------------------- #
# Make a copy
data.raw.filtered.normalized = data.frame(data.raw.filtered)

# Find average and variance of each day of the year
grouped.daily.var = aggregate(MaxTemp ~ Month*Day, data.raw.filtered.normalized, FUN = var)
grouped.daily.var = grouped.daily.var[order(grouped.daily.var$Month, grouped.daily.var$Day), ]
grouped.daily.avg = aggregate(MaxTemp ~ Month*Day, data.raw.filtered.normalized, FUN = mean)
grouped.daily.avg = grouped.daily.avg[order(grouped.daily.avg$Month, grouped.daily.avg$Day), ]

# Normalize data using daily mean and daily variance (function defined in Appendix)
data.raw.filtered.normalized = normalize(data.raw.filtered.normalized, grouped.daily.var, grouped.daily.avg)

# --------------------------- Section 4: Stationarity tests --------------------------- #
# Ljung Box test
Box.Ljung.Test(data.raw.filtered.normalized$MaxTemp, lag = 10)
Box.Ljung.Test(data.raw.filtered.normalized$MaxTemp, lag = 20)
Box.Ljung.Test(data.raw.filtered.normalized$MaxTemp, lag = 30)
Box.Ljung.Test(data.raw.filtered.normalized$MaxTemp, lag = 40)

# Augmented Dickey Fuller test
adf.test(data.raw.filtered.normalized$MaxTemp, output = TRUE)

# --------------------------- Section 5: Stationarity tests --------------------------- #
# Initialize ts object
ts = ts(data.raw.filtered.normalized$MaxTemp, frequency = 1)

# Fit AR models
ar2 <- Arima(ts, order = c(2, 0, 0))
ar3 <- Arima(ts, order = c(3, 0, 0))
ar4 <- Arima(ts, order = c(4, 0, 0)) 

# Plot residuals 
plot(ar2$residuals[1:2000], type = 'l', main = 'AR(2) residuals', ylab = 'Residual')
plot(ar3$residuals[1:2000], type = 'l', main = 'AR(3) residuals', ylab = 'Residual')
plot(ar4$residuals[1:2000], type = 'l', main = 'AR(4) residuals', ylab = 'Residual')

# ACF and PACF of residuals 
acf(ts(ar2$residuals), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(2) residuals')
pacf(ts(ar2$residuals), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'PACF of AR(2) residuals')
acf(ts(ar3$residuals), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(3) residuals')
pacf(ts(ar3$residuals), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'PACF of AR(3) residuals')
acf(ts(ar4$residuals), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(4) residuals')
pacf(ts(ar4$residuals), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'PACF of AR(4) residuals')

# ACF and PACF of residuals^2
acf(ts((ar2$residuals)^2), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(2) squared residuals')
pacf(ts((ar2$residuals)^2), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(2) squared residuals')
acf(ts((ar3$residuals)^2), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(3) squared residuals')
pacf(ts((ar3$residuals)^2), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(3) squared residuals')
acf(ts((ar4$residuals)^2), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(4) squared residuals')
pacf(ts((ar4$residuals)^2), xlim=c(1,50), ylim = c(-0.05, 0.05), main = 'ACF of AR(4) squared residuals')

# QQPlot of residuals
qqPlot(ar2$residuals, ylim = c(-2, 2), cex = 0.3, main = 'QQPlot of AR(2) residuals')
qqPlot(ar3$residuals, cex = 0.3, main = 'QQPlot of AR(3) residuals')
qqPlot(ar4$residuals, cex = 0.3, main = 'QQPlot of AR(4) residuals')


# --------------------------- Section 6: Forecasting --------------------------- #
# Number of days to forecast into the future
H = 10

# AR(2) forecasting
ar2_forecast <- forecast(ar2, h=H)

# Inverse procedures of normalization (function defined in Appendix)
recovered_x = reverse_normalize(ar2$x, grouped.daily.var, grouped.daily.avg, FIRST_DATE)
recovered_fitted = reverse_normalize(ar2$fitted, grouped.daily.var, grouped.daily.avg, FIRST_DATE)

# Adding back the removed seasonal components 
recovered_x = complex(imaginary = imaginary_residuals, real = recovered_x) + seasonal.annual + seasonal.biannual
recovered_fitted = complex(imaginary = imaginary_residuals, real = recovered_fitted) + seasonal.annual + seasonal.biannual

ar2_recovered_forecast_mean = reverse_normalize(ar2_forecast$mean, grouped.daily.var, grouped.daily.avg, FORECAST_FIRST_DATE)
ar2_recovered_forecast_mean = complex(imaginary = imaginary_residuals[1:H], real = ar2_recovered_forecast_mean) + seasonal.annual[1:H] + seasonal.biannual[1:H]  

ar2_recovered_forecast_upper = reverse_normalize(ar2_forecast$upper, grouped.daily.var, grouped.daily.avg, FORECAST_FIRST_DATE)
ar2_recovered_forecast_upper = complex(imaginary = imaginary_residuals[1:H], real = ar2_recovered_forecast_upper) + seasonal.annual[1:H] + seasonal.biannual[1:H]  

ar2_recovered_forecast_lower = reverse_normalize(ar2_forecast$lower, grouped.daily.var, grouped.daily.avg, FORECAST_FIRST_DATE)
ar2_recovered_forecast_lower = complex(imaginary = imaginary_residuals[1:H], real = ar2_recovered_forecast_lower) + seasonal.annual[1:H] + seasonal.biannual[1:H]  

# Plotting
plot(c(42290:42340), Re(recovered_x)[42290:42340], type = 'l', xlim = c(42290,(42340 + H + 1)), ylab = 'Temperature', xlab = 'Day', main = 'AR(2) forecasting, with seasonality and unnormalized')
lines(c(42290:42340), Re(recovered_fitted)[42290:42340], col = 'green', type = 'l')
lines(c(42341:(42340 + H)), Re(ar2_recovered_forecast_mean)[1:H], col = 'blue', type = 'l')
lines(c(42341:(42340 + H)), Re(ar2_recovered_forecast_upper)[1:H], col = 'red', type = 'l')
lines(c(42341:(42340 + H)), Re(ar2_recovered_forecast_lower)[1:H], col = 'red', type = 'l')

# --------------------------- Appendix: definitions of normalize() and reverse_normalize() --------------------------- #
normalize = function(x, grouped_daily_var, grouped_daily_avg){
    for (row in c(1: nrow(x))){
        month = x[row, 2]
        day = x[row, 3]
        
        variance = grouped_daily_var[ which(grouped_daily_var$Month == month & grouped_daily_var$Day == day), ]$MaxTemp
        mean = grouped_daily_avg[ which(grouped_daily_avg$Month == month & grouped_daily_avg$Day == day), ]$MaxTemp
        
        x[row, 4] = (x[row, 4] - mean )/ sqrt(variance)
    }
    
    return(x)
}

reverse_normalize = function(x, grouped_daily_var, grouped_daily_avg, first_date){
    N = length(x)
    y = x
    date = as.Date(first_date) 
    
    for (i in c(0: (N-1))){
#         print(i)
        date = date + i
        day = as.numeric(strftime(date, format = '%d'))
        month = as.numeric(strftime(date, format = '%m'))
        
        variance = grouped_daily_var[ which(grouped_daily_var$Month == month & grouped_daily_var$Day == day), ]$MaxTemp
        mean = grouped_daily_avg[ which(grouped_daily_avg$Month == month & grouped_daily_avg$Day == day), ]$MaxTemp
        
        y[i+1] = (y[i+1] * sqrt(variance)) + mean
    }
    return(y)
}













