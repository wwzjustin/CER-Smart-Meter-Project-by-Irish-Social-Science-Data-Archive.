

myrepo = getOption("repos")
myrepo["CRAN"] = "http://archive.linux.duke.edu/cran/"
options(repos = myrepo)
rm(myrepo)





##summary of data: mean, median, max, 1st and 3rd percentile---------------------------------
summary(meter_before_c)#Records of control group before the test period
summary(meter_before_t)#Records of test group before the test period


summary(meter_test_c) #Records of control group during the test period
summary(meter_test_t) #Records of control group during the test period


# Different stimulus for test groups during the test period
summary(meter_test_sti1)
summary(meter_test_sti2)
summary(meter_test_sti3)
summary(meter_test_sti4)



summary(meter_before_c_July)
summary(meter_before_c_Aug)
summary(meter_before_c_Sep)
summary(meter_before_c_Oct)
summary(meter_before_c_Nov)
summary(meter_before_c_Dec)



summary(meter_before_t_July)
summary(meter_before_t_Aug)
summary(meter_before_t_Sep)
summary(meter_before_t_Oct)
summary(meter_before_t_Nov)
summary(meter_before_t_Dec)


summary(meter_test_c_Jan)  # January has higher electricity usage
summary(meter_test_t_Jan)




summary(meter_test_t_male)
summary(meter_test_t_female)

summary(meter_test_t_age1)
summary(meter_test_t_age7)


summary(meter_test_t_employ1)
summary(meter_test_t_employ2)
summary(meter_test_t_employ7)

summary(meter_test_t_social1)
summary(meter_test_t_social2)
summary(meter_test_t_social6)


summary(meter_test_t_PeopleNumber1)
summary(meter_test_t_PeopleNumber2)
summary(meter_test_t_PeopleNumber3)


summary(meter_test_t_owner)
summary(meter_test_t_rent1)
summary(meter_test_t_rent2)


## packages to show mean and SD-----------------------------------------
#library(tables)
#tabular(Species ~ (Sepal.Length +  Sepal.Width)  *(mean + sd),  data=iris)
install.packages("pastecs")
library(pastecs)
options(scipen=0.1)
options(digits=4)
stat.desc(meter_before_c$kwh, basic=F) 
stat.desc(meter_before_t$kwh, basic=F) 
stat.desc(meter_test_c$kwh, basic=F) 
stat.desc(meter_test_t$kwh, basic=F) 

stat.desc(meter_test_c_male$kwh, basic=F)
stat.desc(meter_test_t_male$kwh, basic=F)
stat.desc(meter_test_c_female$kwh, basic=F)
stat.desc(meter_test_t_female$kwh, basic=F)

stat.desc(meter_test_c_age1$V3, basic=F)

stat.desc(meter_test_c_employ1$V3, basic=F)


stat.desc(meter_test_c_social1$V3, basic=F)


stat.desc(meter_test_c_PeopleNumber1$V3,basic=F)


stat.desc(meter_test_c_owner$V3,basic=F)

stat.desc(meter_test_sti1$V3,basic=F)
stat.desc(meter_test_sti2$V3,basic=F)
stat.desc(meter_test_sti3$V3,basic=F)
stat.desc(meter_test_sti4$V3,basic=F)



## t-test for control and test groups, showing p-value-----------------

t.test(meter_before_c$kwh,meter_before_t$kwh)
t.test(meter_test_c$kwh,meter_test_t$kwh)
t.test(meter_test_c_male$kwh,meter_test_t_male$kwh)
t.test(meter_test_c_age2,meter_test_t_age2)
t.test(meter_test_c_employ1,meter_test_t_employ1)
t.test(meter_test_c_social1,meter_test_t_social1)
t.test(meter_test_c_PeopleNumber1,meter_test_t_PeopleNumber1)
t.test(meter_test_c_owner,meter_test_t_owner)
t.test(meter_test_c_rent1,meter_test_t_rent1)
t.test(meter_test_c_rent2,meter_test_t_rent2)






