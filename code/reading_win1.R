rm(list=ls())   #clear all data
myrepo = getOption("repos")
myrepo["CRAN"] = "http://archive.linux.duke.edu/cran/"
options(repos = myrepo)
rm(myrepo)



#  install packages-------------------
#install.packages("data.table")
library(data.table)




#    set path---------------------------
main_dir <- "/Users/ww89/CER Electricity Revised March 2012/" # setting data folder


# GET PATHS -----------------
files <- list.files(file.path(main_dir), pattern = "^File.*txt$", full.names = T)
assignments <- list.files(file.path(main_dir), pattern = "^SME.*csv$", full.names = T)
ts <- list.files(file.path(main_dir), pattern = "^timeseries.*csv$", full.names = T)


# IMPORT DATA ---------
## consumption data
dts <- lapply(files, fread, sep = " ") # loop through each path and run 'fread' (data.tables import)
dt <- rbindlist(dts) # stack data
setnames(dt, names(dt), c('V1', 'date_cer', 'kwh')) # rename data
dt<-dt[dt$kwh!=0, ];  
setkey(dt, V1, date_cer) # set key to 'id'
rm('dts')

## assignment data
allocation <- fread(assignments, sep = ',', select = c(1:4))
setnames(allocation, names(allocation), c('V1', 'code', 'tariff', 'stimulus')) # change
setkey(allocation, V1)
allocation <- allocation[code == 1] # subset the data to residential only

## time series correction
dt_ts <- fread(ts, sep = ',', drop = c(1,2)) # don't need first two columns
setkey(dt_ts, day_cer, hour_cer)
dt_ts <- dt_ts[day_cer > 194] # not days before 195


# CREATE DAY/HOUR TIME VARIABLES -------------------
dt[, hour_cer := date_cer %% 100] # use modulus to get remainder (hour_cer)
dt[, day_cer := (date_cer - hour_cer)/100] # take of the hour and divide by 100 gets days (day_cer)
dt<-dt[dt$kwh!=0, ];    # exclude missgin data
head(dt) # inspect data


# MERGE DATA ------------------
## merge assignments
dt <- merge(dt, allocation, by = 'V1') # merge
rm('dt_assign') # remove uneeded data
gc() # free up ram by running the 'garbage collector'

## merge time series data
dt <- merge(dt, dt_ts, by = c('day_cer', 'hour_cer')) # merge on key data
setkey(dt, V1, date)
rm('dt_ts')
gc()

tables() # inspect what data tables you have and RAM usage
## FINAL TABLE SIZE: 8.3 gigs (pretty big)

##  pre-survey data
pre_survey<-read.csv("C:\\Users\\ww89\\CER Electricity Revised March 2012\\Survey data - CSV format/Smart meters Residential pre-trial survey data1.csv", head= F, sep=',');

##  post-survey data. Suggest to delete the first line of CSV, this will only have data left, which is easier for coding
post_survey<-read.csv("C:\\Users\\ww89\\CER Electricity Revised March 2012\\Survey data - CSV format/Smart meters Residential post-trial survey data1.csv", head= F, sep=',');




##meter data--------------------------------------------------------------
#For meter records, isolate control and test groups before the test period 
# Based on the time series, segment the data into before, test and post series; note that we could eliminate the first 6 months of the before test
#There are no records for pre-benchmark period,or post-test period

control<-allocation[allocation$stimulus=="E", ];  # E means control group
test   <-allocation[allocation$stimulus!="E", ]; # Others are all test groups


meter_control <- merge(dt,control, by="V1");  # control groups' records before the test period
meter_test<- merge(dt,test, by="V1");



# CREATE NEW VARIABLES ---------------
dt[, trt := 0 + (stimulus!="E")] # create a Treatment tag (trt == 1)
dt[, kwh := kwh*.5] # assuming data is in kw, this creates kwh


# # TOTAL KWH AND DAILY KWH CHECK -------------------
# ## check sample sizes
# n_trt   <- length(unique(dt[trt == 1]$id))
# n_ctrl  <- length(unique(dt[trt == 0]$id))
# c(n_trt, n_ctrl) # 3296 and 929 (checks out)

#tatal_control<-sum(meter_control$kwh, na.rm=FALSE)
#total_test<-sum(meter_test$kwh, na.rm=FALSE)

#days<-365-195+1+365;
#control_daily <-  total_control/(nrow(control))/days # nrow(control)= 929
#test_daily <- total_test/(nrow(test))/days     


# AGGREGATE KWH BY (lots of things) ----------------
dt_agg_hh = dt[, list(kwh = sum(kwh)), keyby = c('V1', 'year', 'month', 'day', 'trt', 'tariff', 'stimulus')] # get total daily kwh per household
dt_mean = dt[, lapply(.SD, mean, na.rm = TRUE), keyby = c('year', 'month', 'day', 'trt', 'tariff', 'stimulus'), .SDcols = c('kwh')]

dt_sum_month =   dt[, lapply(.SD, sum, na.rm = TRUE), keyby = c('year', 'month','trt', 'tariff', 'stimulus'), .SDcols = c('kwh')]


# EXPORT GROUPS BY MEAN----------------

ctrl_only = dt_mean[trt == 0] # get the list of just control group

## loop through and get subsets of treatment
for(i in unique(dt_mean[trt == 1]$tariff)) {
    for(j in unique(dt_mean[trt == 1]$stimulus)) {
        temp_trt = dt_mean[tariff == i & stimulus == j] # create temp data table

        if(nrow(temp_trt) > 0) {

            temp_out = rbindlist(list(ctrl_only, temp_trt), fill = TRUE) # stack the temp treatment data with control data

            ## note use of functions `file.path()` and `paste0()`. look these up. they are awesome.
            write.csv(temp_out, file.path(main_dir, paste0("daily_mean_treatment_",i,j,".csv")),
               row.names = FALSE) # export .csv files
        }
    }
}



# EXPORT GROUPS BY SUM-----------------------------

ctrl_only = dt_sum_month[trt == 0] # get the list of just control group

## loop through and get subsets of treatment
for(i in unique(dt_sum_month[trt == 1]$tariff)) {
    for(j in unique(dt_sum_month[trt == 1]$stimulus)) {
        temp_trt = dt_sum_month[tariff == i & stimulus == j] # create temp data table

        if(nrow(temp_trt) > 0) {

            temp_out = rbindlist(list(ctrl_only, temp_trt), fill = TRUE) # stack the temp treatment data with control data

            ## note use of functions `file.path()` and `paste0()`. look these up. they are awesome.
            write.csv(temp_out, file.path(main_dir, paste0("monthly_sum_treatment_",i,j,".csv")),
               row.names = FALSE) # export .csv files
        }
    }
}


# T-test for monthly sum-------------------------------------------------
library("xlsx")

# two sample t-test for all treatments and control monthly
sum<-read.xlsx("~/Desktop/ISSDA-CER/result/sum_different_treat.xlsx", 1)
t.test(sum$Control, sum$All_treatment,alternative="less",var.equal=T)







#meter_before <- file_test[dt$date_cer>=18100&file_test$date_cer <36549, ];   # records before the test period
#meter_test <- file_test[36600<= file_test$date_cer & file_test$date_cer< 73149, ];    # records in the test period


# Isolate control and test groups during the test period 

meter_before_c <- meter_control[meter_control$date_cer>=18100& meter_control$date_cer <36549, ];  # control groups' records before the test period
meter_before_t <-meter_test[meter_test$date_cer>=18100& meter_test$date_cer <36549, ];   # test groups' records before the test period

meter_test_c <-meter_control[meter_control$date_cer>=36600, ]; # Control groups records in the test period
meter_test_t <-meter_test[meter_test$date_cer>=36600, ];  # Test groups records in the test period











## Segmentation of interviewers based on pre and post survey-----------------------------
#Segmentation of gender, united both pre and post-survey answers for a certain gender
post_survey_male<-post_survey[post_survey[[11]]==1, ][1];  # male
post_survey_female<-post_survey[post_survey[[11]]==2, ][1];  # female

pre_survey_male<-pre_survey[pre_survey[[2]]==1, ][1];
pre_survey_female<-pre_survey[pre_survey[[2]]==2, ][1];

male<-union(pre_survey_male$V1,post_survey_male$V1);
female<-union(pre_survey_female$V1,post_survey_female$V1);

male<-data.frame(male);
female<-data.frame(female);


#Segmentation of age

post_survey_age1<-post_survey[post_survey[[12]]==1, ][1];  # 18-25
post_survey_age2<-post_survey[post_survey[[12]]==2, ][1];  #  25-35
post_survey_age3<-post_survey[post_survey[[12]]==3, ][1];  # 36-45
post_survey_age4<-post_survey[post_survey[[12]]==4, ][1];  # 46-55
post_survey_age5<-post_survey[post_survey[[12]]==5, ][1];  # 56-65
post_survey_age6<-post_survey[post_survey[[12]]==6, ][1];  # above 65
post_survey_age7<-post_survey[post_survey[[12]]==7, ][1];  # not answered


pre_survey_age1<-pre_survey[pre_survey[[3]]==1, ][1];  
pre_survey_age2<-pre_survey[pre_survey[[3]]==2, ][1];  
pre_survey_age3<-pre_survey[pre_survey[[3]]==3, ][1];  
pre_survey_age4<-pre_survey[pre_survey[[3]]==4, ][1];  
pre_survey_age5<-pre_survey[pre_survey[[3]]==5, ][1];  
pre_survey_age6<-pre_survey[pre_survey[[3]]==6, ][1];  
pre_survey_age7<-pre_survey[pre_survey[[3]]==7, ][1];  

age1<-data.frame(union(pre_survey_age1$V1, post_survey_age1$V1));
age2<-data.frame(union(pre_survey_age2$V1, post_survey_age2$V1));
age3<-data.frame(union(pre_survey_age3$V1, post_survey_age3$V1));
age4<-data.frame(union(pre_survey_age4$V1, post_survey_age4$V1));
age5<-data.frame(union(pre_survey_age5$V1, post_survey_age5$V1));
age6<-data.frame(union(pre_survey_age6$V1, post_survey_age6$V1));
age7<-data.frame(union(pre_survey_age7$V1, post_survey_age7$V1));



# Employement status of household income earner
post_survey_employ1<-post_survey[post_survey[[13]]==1, ][1];  # an employee
post_survey_employ2<-post_survey[post_survey[[13]]==2, ][1];  # self employed,with employee
post_survey_employ3<-post_survey[post_survey[[13]]==3, ][1];  # self employed, without employee
post_survey_employ4<-post_survey[post_survey[[13]]==4, ][1];  # umemployed, actively seeking
post_survey_employ5<-post_survey[post_survey[[13]]==5, ][1];  # umeployed, not seeking
post_survey_employ6<-post_survey[post_survey[[13]]==6, ][1];  # retired
post_survey_employ7<-post_survey[post_survey[[13]]==7, ][1];  # carer


pre_survey_employ1<-pre_survey[pre_survey[[4]]==1, ][1];  
pre_survey_employ2<-pre_survey[pre_survey[[4]]==2, ][1];  
pre_survey_employ3<-pre_survey[pre_survey[[4]]==3, ][1];  
pre_survey_employ4<-pre_survey[pre_survey[[4]]==4, ][1];  
pre_survey_employ5<-pre_survey[pre_survey[[4]]==5, ][1];  
pre_survey_employ6<-pre_survey[pre_survey[[4]]==6, ][1];  
pre_survey_employ7<-pre_survey[pre_survey[[4]]==7, ][1];  

employ1<-data.frame(union(pre_survey_employ1$V1, post_survey_employ1$V1));
employ2<-data.frame(union(pre_survey_employ2$V1, post_survey_employ2$V1));
employ3<-data.frame(union(pre_survey_employ3$V1, post_survey_employ3$V1));
employ4<-data.frame(union(pre_survey_employ4$V1, post_survey_employ4$V1));
employ5<-data.frame(union(pre_survey_employ5$V1, post_survey_employ5$V1));
employ6<-data.frame(union(pre_survey_employ6$V1, post_survey_employ6$V1));
employ7<-data.frame(union(pre_survey_employ7$V1, post_survey_employ7$V1));



# Segmentation of social class
post_survey_social1<-post_survey[post_survey[[14]]==1, ][1];  # AB
post_survey_social2<-post_survey[post_survey[[14]]==2, ][1];  # c1
post_survey_social3<-post_survey[post_survey[[14]]==3, ][1];  # c2
post_survey_social4<-post_survey[post_survey[[14]]==4, ][1];  # DE
post_survey_social5<-post_survey[post_survey[[14]]==5, ][1];  # F
post_survey_social6<-post_survey[post_survey[[14]]==6, ][1];  # Refused

pre_survey_social1<-pre_survey[pre_survey[[5]]==1, ][1];  
pre_survey_social2<-pre_survey[pre_survey[[5]]==2, ][1];  
pre_survey_social3<-pre_survey[pre_survey[[5]]==3, ][1];  
pre_survey_social4<-pre_survey[pre_survey[[5]]==4, ][1];  
pre_survey_social5<-pre_survey[pre_survey[[5]]==5, ][1];  
pre_survey_social6<-pre_survey[pre_survey[[5]]==6, ][1];  

social1<-data.frame(union(pre_survey_social1$V1, post_survey_social1$V1));
social2<-data.frame(union(pre_survey_social2$V1, post_survey_social2$V1));
social3<-data.frame(union(pre_survey_social3$V1, post_survey_social3$V1));
social4<-data.frame(union(pre_survey_social4$V1, post_survey_social4$V1));
social5<-data.frame(union(pre_survey_social5$V1, post_survey_social5$V1));
social6<-data.frame(union(pre_survey_social6$V1, post_survey_social6$V1));



# Number of people in the house
post_survey_PeopleNumber1<-post_survey[post_survey[[15]]==1, ][1];  # live alone
post_survey_PeopleNumber2<-post_survey[post_survey[[15]]==2, ][1];  # all people over 15 years old
post_survey_PeopleNumber3<-post_survey[post_survey[[15]]==3, ][1];  # both above and under 15

pre_survey_PeopleNumber1<-pre_survey[pre_survey[[10]]==1, ][1];  
pre_survey_PeopleNumber2<-pre_survey[pre_survey[[10]]==2, ][1];  
pre_survey_PeopleNumber3<-pre_survey[pre_survey[[10]]==3, ][1];  

PeopleNumber1<-data.frame(union(pre_survey_PeopleNumber1$V1, post_survey_PeopleNumber1$V1));
PeopleNumber2<-data.frame(union(pre_survey_PeopleNumber2$V1, post_survey_PeopleNumber2$V1));
PeopleNumber3<-data.frame(union(pre_survey_PeopleNumber3$V1, post_survey_PeopleNumber3$V1));




# Rent or own the house, note the questions of pre and post surveys are different for this 
post_survey_owner<-post_survey[post_survey[[20]]==1, ][1];  # owner of purchasing
post_survey_rent1<-post_survey[post_survey[[20]]==2, ][1];  # rent from agency
post_survey_rent2<-post_survey[post_survey[[20]]==3, ][1];  # rent from private owner

pre_survey_owner<-pre_survey[pre_survey[[36]]==3||4, ][1];  # owner of purchasing
pre_survey_rent1<-pre_survey[pre_survey[[36]]==2, ][1];  # rent from agency
pre_survey_rent2<-pre_survey[pre_survey[[36]]==1, ][1];  # rent from private owner

owner<-data.frame(union(pre_survey_owner$V1, post_survey_owner$V1));
rent1<-data.frame(union(pre_survey_rent1$V1, post_survey_rent1$V1));
rent2<-data.frame(union(pre_survey_rent2$V1, post_survey_rent2$V1));



#Segment different treatment groups in post-surveys
post_survey_OLR<-post_survey[post_survey[[3]]==1, ][1];       # Online rewards
post_survey_IHD<-post_survey[post_survey[[4]]==1, ][1];       # In house disply
post_survey_monthly<-post_survey[post_survey[[5]]==1, ][1];  # Monthly statement. This is energy statement, which is different from billing. Billing is listed in Stimulus
post_survey_bi<-post_survey[post_survey[[6]]==1, ][1];       #Bi-monthly statement

sti1<-allocation[allocation[[4]]==1, ][1];  # stimulus 1
sti2<-allocation[allocation[[4]]==2, ][1];  # stimulus 2
sti3<-allocation[allocation[[4]]==3, ][1];  # stimulus 3
sti4<-allocation[allocation[[4]]==4, ][1];  # stimulus 4







#Isolate control group every month before the test period

meter_before_c_July <-meter_before_c[meter_before_c$V2 >=18100 & meter_before_c$V2 <21249, ]; # July 2009, all the meters settled
meter_before_c_Aug <- meter_before_c[meter_before_c$V2 >=21300 & meter_before_c$V2 <24349, ]; 
meter_before_c_Sep <- meter_before_c[meter_before_c$V2 >=24400 & meter_before_c$V2 <27349, ]; 
meter_before_c_Oct <- meter_before_c[meter_before_c$V2 >=27400 & meter_before_c$V2 <30449, ];
meter_before_c_Nov <- meter_before_c[meter_before_c$V2 >=30500 & meter_before_c$V2 <33449, ]; 
meter_before_c_Dec <- meter_before_c[meter_before_c$V2 >=33500 & meter_before_c$V2 <36549, ];  # Dec 2009


#rm(meter_before);  # Now we only need to use meter_before_c and meter_before_t




#Isolate test group every month before the test period

meter_before_t_July <-meter_before_t[meter_before_t$V2 >=18100 & meter_before_t$V2 <21249, ]; # July 2009, all the meters settled
meter_before_t_Aug <- meter_before_t[meter_before_t$V2 >=21300 & meter_before_t$V2 <24349, ]; 
meter_before_t_Sep <- meter_before_t[meter_before_t$V2 >=24400 & meter_before_t$V2 <27349, ]; 
meter_before_t_Oct <- meter_before_t[meter_before_t$V2 >=27400 & meter_before_t$V2 <30449, ];
meter_before_t_Nov <- meter_before_t[meter_before_t$V2 >=30500 & meter_before_t$V2 <33449, ]; 
meter_before_t_Dec <- meter_before_t[meter_before_t$V2 >=33500 & meter_before_t$V2 <36549, ];  # Dec 2009








#Isolate control group every month during the test period



meter_test_c_Jan   <- meter_test_c[meter_test_c$V2 >=36600 & meter_test_c$V2 <39649, ]; # Jan 2010,test period begins
meter_test_c_Feb   <- meter_test_c[meter_test_c$V2 >=39700 & meter_test_c$V2 <42449, ]; 
meter_test_c_March <- meter_test_c[meter_test_c$V2 >=42500 & meter_test_c$V2 <45549, ]; 
meter_test_c_April <- meter_test_c[meter_test_c$V2 >=45600 & meter_test_c$V2 <48549, ];
meter_test_c_May   <- meter_test_c[meter_test_c$V2 >=48600 & meter_test_c$V2 <51649, ]; 
meter_test_c_Jun <- meter_test_c[meter_test_c$V2 >=51700 & meter_test_c$V2 <54649, ];  
meter_test_c_July <-meter_test_c[meter_test_c$V2 >=54700 & meter_test_c$V2 <57749, ]; 
meter_test_c_Aug <- meter_test_c[meter_test_c$V2 >=57800 & meter_test_c$V2 <60849, ]; 
meter_test_c_Sep <- meter_test_c[meter_test_c$V2 >=60900 & meter_test_c$V2 <63849, ]; 
meter_test_c_Oct <- meter_test_c[meter_test_c$V2 >=63900 & meter_test_c$V2 <66949, ];
meter_test_c_Nov <- meter_test_c[meter_test_c$V2 >=67000 & meter_test_c$V2 <69949, ]; 
meter_test_c_Dec <- meter_test_c[meter_test_c$V2 >=70000 & meter_test_c$V2 <73049, ];  # Dec 2010, test period ends


#Isolate test group every month during the test period

meter_test_t_Jan   <- meter_test_t[meter_test_t$V2 >=36600 & meter_test_t$V2 <39649, ]; # Jan 2010,test period begins
meter_test_t_Feb   <- meter_test_t[meter_test_t$V2 >=39700 & meter_test_t$V2 <42449, ]; 
meter_test_t_March <- meter_test_t[meter_test_t$V2 >=42500 & meter_test_t$V2 <45549, ]; 
meter_test_t_April <- meter_test_t[meter_test_t$V2 >=45600 & meter_test_t$V2 <48549, ];
meter_test_t_May   <- meter_test_t[meter_test_t$V2 >=48600 & meter_test_t$V2 <51649, ]; 
meter_test_t_Jun <- meter_test_t[meter_test_t$V2 >=51700 & meter_test_t$V2 <54649, ];  
meter_test_t_July <-meter_test_t[meter_test_t$V2 >=54700 & meter_test_t$V2 <57749, ]; 
meter_test_t_Aug <- meter_test_t[meter_test_t$V2 >=57800 & meter_test_t$V2 <60849, ]; 
meter_test_t_Sep <- meter_test_t[meter_test_t$V2 >=60900 & meter_test_t$V2 <63849, ]; 
meter_test_t_Oct <- meter_test_t[meter_test_t$V2 >=63900 & meter_test_t$V2 <66949, ];
meter_test_t_Nov <- meter_test_t[meter_test_t$V2 >=67000 & meter_test_t$V2 <69949, ]; 
meter_test_t_Dec <- meter_test_t[meter_test_t$V2 >=70000 & meter_test_t$V2 <73049, ];  # Dec 2010, test period ends






# In the test group, during the test period (meter_test_t), isolate by different stimulus

meter_test_sti1 <-merge(meter_test_t,sti1, by="V1");
meter_test_sti2 <-merge(meter_test_t,sti2, by="V1");
meter_test_sti3 <-merge(meter_test_t,sti3, by="V1");
meter_test_sti4 <-merge(meter_test_t,sti4, by="V1");

meter_test_sti1_2nd<- meter_test_sti1[meter_test_sti1$V2 >=56000, ]; # Jan 2010,test period begins
meter_test_sti2_2nd<- meter_test_sti2[meter_test_sti2$V2 >=56000, ]; # Jan 2010,test period begins
meter_test_sti3_2nd<- meter_test_sti3[meter_test_sti3$V2 >=56000, ]; # Jan 2010,test period begins
meter_test_sti4_2nd<- meter_test_sti4[meter_test_sti4$V2 >=56000, ]; # Jan 2010,test period begins

meter_before_sti1 <-merge(meter_before_t,sti1, by="V1");
meter_before_sti2 <-merge(meter_before_t,sti2, by="V1");
meter_before_sti3 <-merge(meter_before_t,sti3, by="V1");
meter_before_sti4 <-merge(meter_before_t,sti4, by="V1");




# meter data by gender
colnames(male)[1]<-  "V1";
meter_test_t_male<-merge(meter_test_t,male, by="V1");
meter_test_c_male<-merge(meter_test_c,male, by="V1");

colnames(female)[1]<-  "V1";
meter_test_t_female<-merge(meter_test_t,female, by="V1");
meter_test_c_female<-merge(meter_test_c,female, by="V1");




# meter data by age
colnames(age1)[1]<-  "V1";
colnames(age2)[1]<-  "V1";
colnames(age3)[1]<-  "V1";
colnames(age4)[1]<-  "V1";
colnames(age5)[1]<-  "V1";
colnames(age6)[1]<-  "V1";
colnames(age7)[1]<-  "V1";

meter_test_t_age1 <-merge(meter_test_t,age1, by="V1");
meter_test_t_age2 <-merge(meter_test_t,age2, by="V1");
meter_test_t_age3 <-merge(meter_test_t,age3, by="V1");
meter_test_t_age4 <-merge(meter_test_t,age4, by="V1");
meter_test_t_age5 <-merge(meter_test_t,age5, by="V1");
meter_test_t_age6 <-merge(meter_test_t,age6, by="V1");
meter_test_t_age7 <-merge(meter_test_t,age7, by="V1");

meter_test_c_age1 <-merge(meter_test_c,age1, by="V1");
meter_test_c_age2 <-merge(meter_test_c,age2, by="V1");
meter_test_c_age3 <-merge(meter_test_c,age3, by="V1");
meter_test_c_age4 <-merge(meter_test_c,age4, by="V1");
meter_test_c_age5 <-merge(meter_test_c,age5, by="V1");
meter_test_c_age6 <-merge(meter_test_c,age6, by="V1");
meter_test_c_age7 <-merge(meter_test_c,age7, by="V1");



# meter data by employment status
colnames(employ1)[1]<-  "V1";
colnames(employ2)[1]<-  "V1";
colnames(employ3)[1]<-  "V1";
colnames(employ4)[1]<-  "V1";
colnames(employ5)[1]<-  "V1";
colnames(employ6)[1]<-  "V1";
colnames(employ7)[1]<-  "V1";

meter_test_t_employ1<-merge(meter_test_t,employ1, by="V1"); # an employee
meter_test_t_employ2<-merge(meter_test_t,employ2, by="V1"); # self employed,with employee
meter_test_t_employ3<-merge(meter_test_t,employ3, by="V1"); # self employed, without employee
meter_test_t_employ4<-merge(meter_test_t,employ4, by="V1"); # umemployed, actively seeking
meter_test_t_employ5<-merge(meter_test_t,employ5, by="V1"); # umeployed, not seeking
meter_test_t_employ6<-merge(meter_test_t,employ6, by="V1"); # retired
meter_test_t_employ7<-merge(meter_test_t,employ7, by="V1"); # carer


meter_test_c_employ1<-merge(meter_test_c,employ1, by="V1"); # an employee
meter_test_c_employ2<-merge(meter_test_c,employ2, by="V1"); # self employed,with employee
meter_test_c_employ3<-merge(meter_test_c,employ3, by="V1"); # self employed, without employee
meter_test_c_employ4<-merge(meter_test_c,employ4, by="V1"); # umemployed, actively seeking
meter_test_c_employ5<-merge(meter_test_c,employ5, by="V1"); # umeployed, not seeking
meter_test_c_employ6<-merge(meter_test_c,employ6, by="V1"); # retired
meter_test_c_employ7<-merge(meter_test_c,employ7, by="V1"); # 


# meter data by social status
colnames(social1)[1]<-  "V1";
colnames(social2)[1]<-  "V1";
colnames(social3)[1]<-  "V1";
colnames(social4)[1]<-  "V1";
colnames(social5)[1]<-  "V1";
colnames(social6)[1]<-  "V1";

meter_test_t_social1<-merge(meter_test_t,social1, by="V1"); # AB
meter_test_t_social2<-merge(meter_test_t,social2, by="V1"); # c1
meter_test_t_social3<-merge(meter_test_t,social3, by="V1"); # c2
meter_test_t_social4<-merge(meter_test_t,social4, by="V1"); # DE
meter_test_t_social5<-merge(meter_test_t,social5, by="V1"); # F
meter_test_t_social6<-merge(meter_test_t,social6, by="V1"); # Refused

meter_test_c_social1<-merge(meter_test_c,social1, by="V1"); # AB
meter_test_c_social2<-merge(meter_test_c,social2, by="V1"); # c1
meter_test_c_social3<-merge(meter_test_c,social3, by="V1"); # c2
meter_test_c_social4<-merge(meter_test_c,social4, by="V1"); # DE
meter_test_c_social5<-merge(meter_test_c,social5, by="V1"); # F
meter_test_c_social6<-merge(meter_test_c,social6, by="V1"); # Refused


# meter data by family number


colnames(PeopleNumber1)[1]<-  "V1";
colnames(PeopleNumber2)[1]<-  "V1";
colnames(PeopleNumber3)[1]<-  "V1";


meter_test_t_PeopleNumber1<-merge(meter_test_t,PeopleNumber1, by="V1"); # live alone
meter_test_t_PeopleNumber2<-merge(meter_test_t,PeopleNumber2, by="V1"); # all people over 15 year
meter_test_t_PeopleNumber3<-merge(meter_test_t,PeopleNumber3, by="V1"); # both above and under 15

meter_test_c_PeopleNumber1<-merge(meter_test_c,PeopleNumber1, by="V1"); # live alone
meter_test_c_PeopleNumber2<-merge(meter_test_c,PeopleNumber2, by="V1"); # all people over 15 year
meter_test_c_PeopleNumber3<-merge(meter_test_c,PeopleNumber3, by="V1"); # both above and under 15




# meter data b renting/owner


colnames(owner)[1]<-  "V1";
colnames(rent1)[1]<-  "V1";
colnames(rent2)[1]<-  "V1";


meter_test_t_owner<-merge(meter_test_t,owner, by="V1");
meter_test_t_rent1<-merge(meter_test_t,rent1, by="V1"); 
meter_test_t_rent2<-merge(meter_test_t,rent2, by="V1");


meter_test_c_owner<-merge(meter_test_c,owner, by="V1");
meter_test_c_rent1<-merge(meter_test_c,rent1, by="V1"); 
meter_test_c_rent2<-merge(meter_test_c,rent2, by="V1");




