# Time Series Project - Analysis of Daily Maximum Temperature at Melbourne, Australia

In this project, our chosen dataset is a record of the daily maximum air temperature taken in Melbourne Regional Oﬃce (site opened in 1908 and closed at January, 6th 2015). We have successfully constructed a consistent forecasting model using ARMA models. The main components of this study includes:
- Visualization of the time series
- Removing the seasonal component
	- STL
	- Differencing
	- Spectral filter
- Normalization
- Modeling with AR(2), AR(3), AR(4) and ARMA(2,0)-GARCH(1,1)
- Assesing model residuals using ACF, PACF, QQPlots, Ljung-Box test, ADF test
- Forecasting


<figure align="center">
	<p align="center">
	  <img src="https://github.com/wywongbd/EPFL-Time-Series/blob/master/project/plots/raw-ts/first5percent.jpg" align="middle">
	  <figcaption> This is a plot of the first 5% of the entire time series used in our study. We observe that there is clearly a seasonal component with a period T = 1 year = 365 days approximately. This is reasonable and most likely an instance of climate oscillation. This is a strong indication that temperature series is not a stationary time series. Thus, we need to remove this seasonal component, because the ARMA models are built for stationary time series.  </figcaption>
	</p>
</figure>

<figure align="center">
	<p align="center">
	  <img src="https://github.com/wywongbd/EPFL-Time-Series/blob/master/project/plots/filtering/TS-before-and-after.jpg" align="middle">
	  <figcaption> This plot illustrates effect of the removing seasonal component from the time series. The filtering step can be summarized as follows: First, perform Fourier transform on original time series. Then, use a spectral ﬁlter to ﬁlter out frequencies that correspond to the seasonal components in the data (with the help of a periodogram). Finally, perform inverse Fourier transform to obtain data without seasonal trend. The resulting time series is no longer seasonal, but is obviously still not stationary due to the non-constant variance. </figcaption>
	</p>
</figure>

<figure align="center">
	<p align="center">
	  <img src="https://github.com/wywongbd/EPFL-Time-Series/blob/master/project/plots/normalization/Normalization-before-and-after.jpg" align="middle">
	  <figcaption> This plot illustrates effect of normalization on the filtered time series. The normalization is done using daily mean and daily standard deviation. Results of Ljung Box test, ACF and PACF confirm that the normalized series is stationary (see report folder for more details).
	  </figcaption>
	</p>
</figure>

<figure align="center">
	<p align="center">
	  <img src="https://github.com/wywongbd/EPFL-Time-Series/blob/master/project/plots/modeling/ARMA/forecasting/ar2-forecasting-recovered-360days-with-obs.jpg" align="middle">
	  <figcaption> The predicted maximum daily temperature as function of time (day). This plot contains 500 forecasted values. We observe that most of the future measured data are contained within the forecasted 95% confidence interval. Additionally, the conﬁdence band is bigger in summer (high temperature) and smaller in winter (low temperature), which is consistent with our initial observation that temperature varies more erratically in summer than in winter.</figcaption>
	</p>
</figure>
  

For detailed information of our modeling procedures, please refer to the [report](https://github.com/wywongbd/EPFL-Time-Series/tree/master/project/report) folder.

