library(data.table)

# # TOTAL KWH CHECK -------------------
# ## check sample sizes
# n_trt   <- length(unique(dt[trt == 1]$id))
# n_ctrl  <- length(unique(dt[trt == 0]$id))
# c(n_trt, n_ctrl) # 3296 and 929 (checks out)

# ## sum kwh i.e. trial/benchmark
# dt[, list(sum_kwh = sum(kwh)), by = 'trt'] # sum during trial

# AGGREGATE KWH BY (lots of things) ----------------
dt_agg_hh = dt[, list(kwh = sum(kwh)), keyby = c('V1', 'year', 'month', 'day', 'trt', 'tariff', 'stimulus')] # get total daily kwh per household
dt_mean = dt[, lapply(.SD, mean, na.rm = TRUE), keyby = c('year', 'month', 'day', 'trt', 'tariff', 'stimulus'), .SDcols = c('kwh')]


dt_sum_month =   dt[, lapply(.SD, sum, na.rm = TRUE), keyby = c('year', 'month','trt', 'tariff', 'stimulus'), .SDcols = c('kwh')]
dt_sum_month_id =   dt[, lapply(.SD, sum, na.rm = TRUE), keyby = c('year', 'month','trt', 'V1','tariff', 'stimulus'), .SDcols = c('kwh')]


dt_sum_day_id =   dt[, lapply(.SD, sum, na.rm = TRUE), keyby = c('year', 'month','day','trt', 'V1','tariff', 'stimulus'), .SDcols = c('kwh')]
dt_summary_day_id = dt_sum_day_id[, list(kwh_mean = mean(kwh), kwh_sd = sd(kwh), n = .N), keyby = c('year', 'month', 'day', 'trt', 'tariff', 'stimulus')] # get total daily kwh per household



# EXPORT GROUPS BY DAILY MEAN with dt_mean---------------------------

ctrl_only = dt_mean[trt == 0] # get the list of just control group

## loop through and get subsets of treatment
for(i in unique(dt_mean[trt == 1 & tariff != "b" ]$tariff)) {
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


# EXPORT GROUPS BY TOTAL SUM BY MONTH with dt_month -----------------------------

ctrl_only = dt_sum_month[trt == 0] # get the list of just control group

## loop through and get subsets of treatment
for(i in unique(dt_sum_month[trt == 1 & tariff != "b"]$tariff)) {
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


## T-test for monthly sumlibrary("xlsx")
## two sample t-test for all treatments and control monthly
sum<-read.xlsx("~/Desktop/ISSDA-CER/result/sum_different_treat.xlsx", 1)
t.test(sum$Control, sum$All_treatment,alternative="less",var.equal=T)

# EXPORT GROUPS BY SUM BY HOUSEHOLDS MONTHLY with dt_sum_month_id----------------------------------------------

ctrl_only = dt_sum_month_id[trt == 0] # get the list of just control group
trt_only=dt_sum_month_id[trt == 1]

## loop through and get subsets of treatment
for(i in unique(dt_sum_month_id[trt == 1 & tariff != "b"]$tariff)) {
    for(j in unique(dt_sum_month_id[trt == 1]$stimulus)) {
        for ( k in unique(dt_sum_month_id[year== 2009]$month))  {
       temp_trt = dt_sum_month_id[year == 2010 & tariff == "B" & stimulus == 1 & month == 12] # create temp data table
       temp_ctrl= ctrl_only[year == 2010 & month ==12]
         a1<-t.test(temp_trt$kwh, temp_ctrl$kwh,alternative="less",var.equal=T)
           # write.csv(temp_trt, file.path(main_dir, paste0("monthly_sum_treatment_id",i,j,".csv")),
           #row.names = FALSE) # export .csv files
      }
    }
}


## Compare distributions for different treatments and control group
library("sm")
attach(mtcars)
B1_id<-read.csv("~/Desktop/ISSDA-CER/result/sum_month_id/monthly_sum_treatment_B1.csv", head=T)



## create value labels 
tariff.f<- factor(B1_id$tariff, levels= c("B","E"),
labels = c("B1", "Control")) 


## plot histogram
E <- B1_id[B1_id$tariff=="E", ]
B1 <-B1_id[B1_i$tariff=="A", ]
hist(E$kwh)

## plot densities 

sm.density.compare(B4_id$kwh, B4_id$tariff, xlab="Kwh per month")
title(main="Density Distribution of B4 and Control")

## add legend via mouse click
colfill<-c(2:(2+length(levels(tariff.f)))) 
legend(locator(1), levels(tariff.f), fill=colfill)


# EXPORT GROUPS BY TOTAL SUM BY DAY with dt_summary_day_id -----------------------------

ctrl_only = dt_summary_day_id[trt == 0] # get the list of just control group

## loop through and get subsets of treatment
for(i in unique(dt_summary_day_id[trt == 1 & tariff != "b"]$tariff)) {
    for(j in unique(dt_summary_day_id[trt == 1]$stimulus)) {
        temp_trt = dt_summary_day_id[tariff == i & stimulus == j] # create temp data table

        if(nrow(temp_trt) > 0) {
                ## note use of functions `file.path()` and `paste0()`. look these up. they are awesome.
            write.csv(temp_trt, file.path(main_dir, paste0("summary_day_id_treatment",i,j,".csv")),
               row.names = FALSE) # export .csv files
        }
    }
}
write.csv(ctrl_only, file.path(main_dir, paste0("summary_day_id_ctrl.csv")))





