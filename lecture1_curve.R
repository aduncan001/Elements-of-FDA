library(fda)

# Curve Registration

# Let us experiment a bit with the continuous curve registration features offered 
# in the fda package.  We shall re-produce the growth acceleration example in the notes, 
# using the Berkley height dataset. 

age=growth$age
heightBasis=create.bspline.basis( c(1,18), 35, 6, age) 
heightPar=fdPar(heightBasis, 3, 10^(-0.5)) 
heightSmooth=smooth.basis(age, growth$hgtf, heightPar)
plot(heightSmooth, lwd=2, xlab="age", ylab="height (cm)")

# compute the acc

accelUnreg = deriv.fd(heightSmooth$fd, 2) 
plot(accelUnreg[,1], lwd=2, xlab="Age", ylab="Acceleration",ylim=c(-4,2)) 
mean.accelUnreg=mean(accelUnreg) 
lines(mean.accelUnreg, lwd=4, col="black")

# Let's use the register.fd package to perform continuous registration
regList=register.fd(yfd=accelUnreg) 
accelReg=regList$regfd
plot(accelReg, xlab="Age", ylab="Acceleration", ylim=c(-4,3))

#compare the difference between the two.

