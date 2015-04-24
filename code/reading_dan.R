rm(list=ls())   #clear all data

library(data.table)

main_dir <- "/Users/dnoriega/Desktop/ISSDA-CER/CER Electricity Revised March 2012/" # setting data folder

# GET PATHS -----------------
files <- list.files(file.path(main_dir), pattern = "^File.*txt$", full.names = T)
assignments <- list.files(file.path(main_dir), pattern = "^SME.*csv$", full.names = T)
ts <- list.files(file.path(main_dir), pattern = "^timeseries.*csv$", full.names = T)


# IMPORT DATA ---------
## consumption data
dts <- lapply(files, fread, sep = " ") # loop through each path and run 'fread' (data.tables import)
dt <- rbindlist(dts) # stack data
setnames(dt, names(dt), c('id', 'date_cer', 'kw')) # rename data
setkey(dt, id, date_cer) # set key to 'id'
rm('dts')

## assignment data
dt_assign <- fread(assignments, sep = ',', select = c(1:4))
setnames(dt_assign, names(dt_assign), c('id', 'code', 'tariff', 'stimulus')) # change
setkey(dt_assign, id)
dt_assign <- dt_assign[code == 1] # subset the data to residential only

## time series correction
dt_ts <- fread(ts, sep = ',', drop = c(1,2)) # don't need first two columns
setkey(dt_ts, day_cer, hour_cer)
dt_ts <- dt_ts[day_cer > 194] # not days before 195


# CREATE DAY/HOUR TIME VARIABLES -------------------
dt[, hour_cer := date_cer %% 100] # use modulus to get remainder (hour_cer)
dt[, day_cer := (date_cer - hour_cer)/100] # take of the hour and divide by 100 gets days (day_cer)
head(dt) # inspect data


# MERGE DATA ------------------
## merge assignments
dt <- merge(dt, dt_assign, by = 'id') # merge
rm('dt_assign') # remove uneeded data
gc() # free up ram by running the 'garbage collector'

## merge time series data
dt <- merge(dt, dt_ts, by = c('day_cer', 'hour_cer')) # merge on key data
setkey(dt, id, date)
rm('dt_ts')
gc()

tables() # inspect what data tables you have and RAM usage
## FINAL TABLE SIZE: 8.3 gigs (pretty big)

# CREATE NEW VARIABLES ---------------
dt[, trt := 0 + (stimulus!="E")] # create a Treatment tag (trt == 1)
dt[, kwh := kw*.5] # assuming data is in kw, this creates kwh


# # TOTAL KWH CHECK -------------------
# ## check sample sizes
# n_trt   <- length(unique(dt[trt == 1]$id))
# n_ctrl  <- length(unique(dt[trt == 0]$id))
# c(n_trt, n_ctrl) # 3296 and 929 (checks out)

# ## sum kwh i.e. trial/benchmark
# dt[, list(sum_kwh = sum(kwh)), by = 'trt'] # sum during trial

# AGGREGATE KWH BY (lots of things) ----------------
dt_agg_hh = dt[, list(kwh = sum(kwh)), keyby = c('id', 'year', 'month', 'day', 'trt', 'tariff', 'stimulus')] # get total daily kwh per household
dt_mean = dt[, lapply(.SD, mean, na.rm = TRUE), keyby = c('year', 'month', 'day', 'trt', 'tariff', 'stimulus'), .SDcols = c('kwh')]


# EXPORT GROUPS ----------------

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




