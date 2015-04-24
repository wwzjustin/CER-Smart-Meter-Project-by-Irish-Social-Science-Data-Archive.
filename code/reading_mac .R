rm(list=ls())   #clear all data


#reading raw data, each files has arround a 20 millon rows that can slow down the caculation; read only 1000,000 rows for test


#file1<-read.table("~/Documents/ISSDA-CER/CER Electricity Revised March 2012/File1.txt")
file1_test<-read.table("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/File1.txt", nrows=1000);
file2_test<-read.table("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/File2.txt", nrows=1000);
file3_test<-read.table("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/File3.txt", nrows=1000);
file4_test<-read.table("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/File4.txt", nrows=1000);
file5_test<-read.table("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/File5.txt", nrows=1000);
file6_test<-read.table("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/File6.txt", nrows=1000);

file_test<-rbind(file1_test,file2_test,file3_test,file4_test,file5_test,file6_test);    #combine all the files together


# Based on the time series, segment the data into before, test and post series; note that we could eliminate the first 6 months of the before test
meter_pre <- file_test[file_test$V2<18100,  ];
meter_before <- file_test[file_test$V2>=18100 & file_test$V2 <36549, ];
meter_test <- file_test[36600<= file_test$V2 & file_test$V2< 73149, ];
#meter_post <- file_test[file_test$V2>=73200,];    # Actually, there are no post-test data collected

#meter_before_order<-meter_before[ order(meter_before[,1]),];    # Order ascend by Id
#meter_test_order<-meter_test[ order(meter_before[,1]),];    # Order ascend by Id
#meter_post_order<-meter_post[ order(meter_before[,1]),];    # Order ascend by Id


# load the post-survey data, based on which we know which meter is control or test group


pre_survey<-read.csv("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/Survey data - CSV format/Smart meters Residential pre-trial survey data1.csv", head= F, sep=',');





# load the post-survey data, based on which we know which meter is control or test group
# Suggest to delete the first line of CSV, this will only have data left, which is easier for coding


post_survey<-read.csv("~/Desktop/ISSDA-CER/CER Electricity Revised March 2012/Survey data - CSV format/Smart meters Residential post-trial survey data1.csv", head= F, sep=',');


post_survey_c<-post_survey[post_survey[[2]]==1, ]; # answer 1 is the control group
post_survey_t<-post_survey[post_survey[[2]]==2, ];
p<-length(post_survey_c[[1]]);
q<-length(post_survey_t[[1]]);

post_survey_OLR<-post_survey[post_survey[[3]]==1, ];
post_survey_IHD<-post_survey[post_survey[[4]]==1, ];
post_survey_monthly<-post_survey[post_survey[[5]]==1, ];  # this is energy statement, different from billing. Billing is in Stimulus
post_survey_bi<-post_survey[post_survey[[6]]==1, ];

post_survey_sti1<-post_survey[post_survey[[10]]==1, ];
post_survey_sti2<-post_survey[post_survey[[10]]==2, ];
post_survey_sti3<-post_survey[post_survey[[10]]==3, ];
post_survey_sti4<-post_survey[post_survey[[10]]==4, ];

post_survey_male<-post_survey[post_survey[[11]]==1, ][1];  # male
post_survey_female<-post_survey[post_survey[[11]]==2, ][1];  # female
pre_survey_male<-pre_survey[pre_survey[[2]]==1, ][1];
pre_survey_female<-pre_survey[pre_survey[[2]]==2, ][1];

male<-union(pre_survey_male$V1,post_survey_male$V1);
female<-union(pre_survey_female$V1,post_survey_female$V1);

post_survey_male<-data.frame(male);
post_survey_female<-data.frame(female);



#meter_before_c<-NULL
#n<-length(meter_before[[1]])
#       Colunmnize and extract the data with same metetID f
#or (j in 1:n){
 #   	b<-meter_before_order$V1[j];
  #        if(meter_before_order$V1[j+1]==b)   
   #         {meter_before_c<-rbind(meter_before_c, meter_before_order[j+1,],meter_before_order[j,]);  	 
    #                   j=j+1;  }           
     #   	else j=j+1;
	  #       }






# Isolate c and t groups for before, test and post meter data



colnames(post_survey_c[,1:2])[1] <- "V1"
meter_before_c <- merge(meter_before,post_survey_c[,1:2],by="V1");  # extract residents that have always been control groups before, in and after-test
#meter_before_c <-merge(meter_before,post_survey_c, by="V1")[1:3];  The same with above
meter_before_t <-merge(meter_before,post_survey_t, by="V1")[1:3];

#rm(meter_before);




meter_test_c <-merge(meter_test,post_survey_c$V1)
meter_test_t <-merge(meter_test,post_survey_t, by="V1")[1:3];
#rm(meter_test);


meter_test_sti1<-merge(meter_test_t,post_survey_sti1, by="V1")[1:3];
meter_test_sti2 <-merge(meter_test_t,post_survey_sti2, by="V1")[1:3];
meter_test_sti3 <-merge(meter_test_t,post_survey_sti3, by="V1")[1:3];
meter_test_sti4 <-merge(meter_test_t,post_survey_sti4, by="V1")[1:3];




#meter_post_c <-merge(meter_post,post_survey_c, by="V1")[1:3];
#meter_post_t <-merge(meter_post,post_survey_t, by="V1")[1:3];

# meter data by gender
colnames(post_survey_male)[1]<-  "V1";
meter_test_t_male<-merge(meter_test_t,post_survey_male, by="V1")[1:3];
meter_test_c_male<-merge(meter_test_c,post_survey_male[,1:2], by="V1")[1:3];

colnames(post_survey_female[,1:2])[1]<-  "V1";
meter_test_t_female<-merge(meter_test_t,post_survey_female[,1:2], by="V1")[1:3];
meter_test_c_female<-merge(meter_test_c,post_survey_female[,1:2], by="V1")[1:3];




   
#latex(tabular(Species ~ (Sepal.Length +  Sepal.Width)  *(mean + sd),  data=iris))
tabular(Species ~ (Sepal.Length +  Sepal.Width)  *(mean + sd),  data=iris)





