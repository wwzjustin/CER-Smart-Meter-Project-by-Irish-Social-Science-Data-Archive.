# Notes of Codes and Results: On GitHub


[justinishere][dl] (GitHub)

[dl]: https://github.com/justinishere/Justin_CER


##Folder of results
### 1. summary table: mean and SD of segmentation
* Revising from sheet 1 to sheet 3. Sheet 1 all based on post survey anser
* **sheet 2 merged answers of pre-survey with post-survey**
* Sheet 3 realized missing data was not eliminated before


### 2. daily mean
* mean= sum usage of that day/Number of meters；16 graphs of mean of daily electricity usage
* No. of households: A around 290 each, B 110, C 299, D 105
* **distribution**
   * A1-4 treatment > control 
   * B1 treatment< control， B 2-3 treatment > control, B4 treatment >> control
   * C1-4 treatment > control
   * D1 treatment = control, D2 and 3 treatment > control, D3 treatment < control

### 3. sum all
* daily and monthly sum of electricity usage- **all treatment groups together**


### 4. sum_month
* The Excel is monthly sum of electricity usage-**16 different groups**
* **This file can be used to calculate the ratio Rt and Rc**
* The folder 'sum month' is the detailed data 

### 5. sum_month_id
* This is monthly sum of **each smart meter ID** of 16 different groups
* T-test by month, with graphs. We have A1, B4, B1 vs. Control now.
* The folder 'sum month id' is the detailed data 

### 6. summary_day_id
* Daily t stat calculated from mean and SD, with graphs
* The folder is the detailed data

### 7. T-est_day_id
* Aggregated T-test graphs of all 16 treatment groups

### 8. B1 and D3:  chosen based on daily mean and t-test

-----------
##Folder of code

### 1. reading_win1
* Time series: I manually checked the time_series correction file with my method. Both correct. (Benchmark period 19501 to 36548; test period 36600 to 73048)
* For date of segmentation I used the manual time series method

### 2. reading_dan: Danton's sample code

### 3. daily test: a 'laborous' version of getting daily means


### 4. mean+sum check
* codes where most of the Excel results derived 


-------------

##Folder of markdown
* .md files and graphs used


--------

##Folder of 'Paper'-other publications on CER
* 'Knime' used clustering method; on P8 we have the reference for actual unit (kw * 30 minutes), not Kwh


### see also the 'time_series correction' and 'allocation'


------

  

#Acknowledgements <a id="acknowledgements" />


[Danton Noriega][] has helped me a lot with R programming. He is a mater. I would also like to appreciate [Matthew Harding][] for giving me the chance of working on this project.

  [Danton Noriega]:		https://github.com/ultinomics
  [Matthew Harding]:    http://people.duke.edu/~mch55/
  