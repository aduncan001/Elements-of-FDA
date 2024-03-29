# We illustrate the entire discussed procedure using log– precipitation data. 
#This data was collected across several stations in Canada and is commonly used 
#in the FDA literature to illustrate new methodologies.

library(fda)
data(CanadianWeather)
attach(CanadianWeather)


# extract precipitation daily averages in Vancouver
y.precip=dailyAv[,,2]
l = which(place=="Vancouver") 
t.day = 1:365  
y=y.precip[,l]

#let's plot the data
plot(t.day, y, type="n",lwd=4, col="black",
     xlab="day", ylab="precipitation", 
     main="Vancouver Precipitation", cex=1)
points(t.day, y, pch=1, cex=.5, col="blue", lwd=1)


# Let's introduce some smoothing using a spline basis, 
# by specifying the number of basis elements:

#Create a  spline basis over the interval (1,365) of order 4, 
#with the specific number of basis
nbasis <- 10
ybasis  <- create.bspline.basis(rangeval = c(1,365), nbasis = nbasis, norder=4)

#do the smoothng
dayprecfd <- smooth.basis(t.day, y, ybasis)$fd 

main.label = paste("Vancouver (nbasis =", nbasis, ")", sep="")
plot(t.day, y, type="n", ylim=range(y), 
     ylab="Precipitation", xlab="day", main=main.label)
points(t.day, y, pch=1, cex=.5, col="blue", lwd=1)
lines(dayprecfd,col="red",lwd=4)

#Now let's do it by introducing a penalty function.  We shall use int2Lfd(m) to 
# introduce an m-derivative penalty term.  fdPar() : defines functional parameters; 
# in this case the 2nd order derivative penalty term and the smoothing parameter.
lambda <- 10^6

tD2fdPar = fdPar(ybasis, Lfdobj=int2Lfd(2), lambda=lambda)

# smooth.basis() : smoothes the data using the roughness penalty and smoothing parameter specified in 'tD2fdPar' 
dayprecfd = smooth.basis(t.day,y,tD2fdPar)$fd

main.label = paste("Vancouver (lambda =", round(lambda,2), ")", sep="")
plot(t.day, y, type="n", ylim=range(y), 
     ylab="Precipitation", xlab="day", main=main.label)
points(t.day, y, pch=1, cex=.5, col="blue", lwd=1)
lines(dayprecfd,col="red",lwd=4)

# How do we select the optimal roughness penalty lambda? 
#We can use cross-validation, generalized cross-validation, 
#restricted maximum liklihood (reML) estimation, etc. 
#The following code uses GCV to select optimal parameter from 50 candidates.

loglambda=seq(-5, 12, len=71)  
#print the range  of the lambda
range(exp(loglambda))

gcv = rep(0,71)

for(i in c(1:length(loglambda))){
  lambda=exp(loglambda[i])
  
  tD2fdPar = fdPar(ybasis,Lfdobj=int2Lfd(2),lambda=lambda)
  tyfd = smooth.basis(t.day,y,tD2fdPar)
  
  gcv[i] = tyfd$gcv
}

# PLOT GCV of FIT versus log lambda
plot(loglambda,gcv[1:71],type='l',cex.lab=1.5, lwd=4, 
     xlab='log lambda',ylab='GCV', main="GCV(log.lambda)")

# Let's find the minimum
index.logl.opt = which(gcv==min(gcv))
lambda.opt = exp(loglambda[index.logl.opt])
tD2fdPar = fdPar(ybasis,Lfdobj=int2Lfd(2),lambda=lambda.opt)
tyfd = smooth.basis(t.day,y,tD2fdPar)

plot(t.day, y, type="n", ylab="Precipitation", xlab="day", ylim=range(y), 
     main=paste("optimal lambda = ", round(lambda.opt)))
points(t.day, y, pch=1, cex=.5, col="blue", lwd=1)
lines(tyfd$fd,col="red",lwd=4)


# Derivatives Once we have recovered a smooth curve associated with the functional data,
# we can also analyse rate of change properties, for example, places where the derivative
# crosses the x-axis, etc. These ar crucial in identifying significant changes in trend 
# -- however one must be careful that the derivatives are not too heavily influenced by 
# a poor choice of smoothing parameters.  Once you obtain the derivative curves 
# -- then confidence intervals etc can be derived and one can test whether the trend 
# in a given region is significant.

dayprec_dt <- deriv.fd(dayprecfd, 1)
plot(dayprec_dt, type="n", ylab="Rate of Change Precipitation", xlab="day")

# Kernel Smoothing

# Let us now try and do some kernel smoothing instead. We can use the ksmooth function. 
# The critical parameter here is the parameter h which controls the bandwidth

h = 100
fit = ksmooth(t.day, y, kernel = c("box"), bandwidth = h)
plot(t.day, y, type="n", ylab="Precipitation", 
     xlab="day", ylim=range(y), 
     main="Kernel Smoothing")
points(t.day, y, pch=1, cex=.5, col="blue", lwd=1)
lines(t.day, fit$y, col="red", lwd=2)

# Curve Registration

# Let us experiment a bit with the continuous curve registration features offered 
# in the fda package.  We shall re-produce the growth acceleration example in the notes, 
# using the Berkley height dataset. 


