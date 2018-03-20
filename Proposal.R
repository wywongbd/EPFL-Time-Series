library(zoo)
library(xts)
library(ggplot2)
library(TSA)
library(seewave)

mydaily=readRDS('mydata.rds')
mydaily=mydaily[4746:47085]
mymonthly=apply.monthly(mydaily$`Maximum temperature`,mean)


mydaily$Quality[which(mydaily$Quality == -1)]=0
mydaily$Quality[which(mydaily$Quality == 1)]=NA

a = ggplot( data=mymonthly, aes(x=index(mymonthly)) ) + geom_line( aes( y = as.numeric(mymonthly$`Maximum temperature`) )  )
a = a + labs(x='Date',y='Maximum temperature (C°)') + ggtitle('Monthly maximum air temperature in Melbourne, from 01-01-1855 to 05-01-2015')

g = ggplot( data=mydaily, aes( x=index(mydaily)))+labs(x='Date',y='Maximum temperature (C°)')
g = g + geom_line( aes(y= as.numeric( mydaily$`Maximum temperature`),colour='green') ) + scale_y_discrete()
g = g + geom_point( aes(y = as.numeric(mydaily$Quality)+mean(na.rm=TRUE,as.numeric(mydaily$`Maximum temperature`) ) ,colour='red')  )
g = g + ggtitle('Daily maximum air temperature in Melbourne, from 01-01-1855 to 05-01-2015')
g = g + geom_vline(xintercept = as.numeric(index(mydaily)[c(4900,56900)])  , color = "blue", size=1)
g = g + scale_color_manual(name = "Data", labels = c("good", "bad"), values = c('black','red'))
g

t = ggplot( data=mydaily, aes( x=index(mydaily)))
t = t + labs(x='Date',y='Maximum temperature (C°)')
t = t + geom_line( aes(y= as.numeric( mydaily$`Maximum temperature`)))
t = t + ggtitle('Daily maximum air temperature in Melbourne, from 01-01-1855 to 05-01-2015')

myMax=ts(as.numeric(mydaily$`Maximum temperature`),frequency = 55)
mySTL=stl(myMax,"periodic")
# plot(mySTL$time.series[,'seasonal'][400:1200],type='l')
# plot(mySTL$time.series[,'trend'][400:1200],type='l')

myperiodogram=periodogram(as.numeric(mydaily$`Maximum temperature`),log = 'yes')


################### need to set to zero some value of spectrum
plot(myMax[100:600]-Re(ifft(myperiodogram$spec))[100:600],type='l')
