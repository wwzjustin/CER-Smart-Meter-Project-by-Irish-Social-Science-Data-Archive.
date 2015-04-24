

# average daily kwh during benchmark period---------------------------------
control_daily<-NULL
mid1<-meter_control[c(3,5)]

for (i in 195:730){

    a<-mid1[mid1$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/929
    control_daily<-c(control_daily,c)
    i=i+1;   }

# average daily kwh during test period---------------------------------

test_daily<-NULL
mid2<-meter_test[c(3,5)]

for (i in 195:730){

    a<-mid2[mid2$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/3296
    test_daily<-c(test_daily,c)
    i=i+1;   }

control_daily<-data.frame(control_daily)
test_daily<-data.frame(test_daily)

rm(a,b,c,mid1,mid2)
#write.csv(control_daily, file="C:/Users/ww89/control.csv")
#write.csv(test_daily, file="C:/Users/ww89/test.csv")



# Segment into tariff and stimulus-----------
A1<-allocation[allocation$stimulus==1& allocation$tariff=="A", ];
A2<-allocation[allocation$stimulus==2& allocation$tariff=="A", ];
A3<-allocation[allocation$stimulus==3& allocation$tariff=="A", ];
A4<-allocation[allocation$stimulus==4& allocation$tariff=="A", ];
B1<-allocation[allocation$stimulus==1& allocation$tariff=="B", ];
B2<-allocation[allocation$stimulus==2& allocation$tariff=="B", ];
B3<-allocation[allocation$stimulus==3& allocation$tariff=="B", ];
B4<-allocation[allocation$stimulus==4& allocation$tariff=="B", ];
C1<-allocation[allocation$stimulus==1& allocation$tariff=="C", ];
C2<-allocation[allocation$stimulus==2& allocation$tariff=="C", ];
C3<-allocation[allocation$stimulus==3& allocation$tariff=="C", ];
C4<-allocation[allocation$stimulus==4& allocation$tariff=="C", ];
D1<-allocation[allocation$stimulus==1& allocation$tariff=="D", ];
D2<-allocation[allocation$stimulus==2& allocation$tariff=="D", ];
D3<-allocation[allocation$stimulus==3& allocation$tariff=="D", ];
D4<-allocation[allocation$stimulus==4& allocation$tariff=="D", ];

meter_test_A1<- merge(meter_test,A1, by="V1")[1:15];
meter_test_A2<- merge(meter_test,A2, by="V1")[1:15];
meter_test_A3<- merge(meter_test,A3, by="V1")[1:15];
meter_test_A4<- merge(meter_test,A4, by="V1")[1:15];
meter_test_B1<- merge(meter_test,B1, by="V1")[1:15];
meter_test_B2<- merge(meter_test,B2, by="V1")[1:15];
meter_test_B3<- merge(meter_test,B3, by="V1")[1:15];
meter_test_B4<- merge(meter_test,B4, by="V1")[1:15];
meter_test_C1<- merge(meter_test,C1, by="V1")[1:15];
meter_test_C2<- merge(meter_test,C2, by="V1")[1:15];
meter_test_C3<- merge(meter_test,C3, by="V1")[1:15];
meter_test_C4<- merge(meter_test,C4, by="V1")[1:15];
meter_test_D1<- merge(meter_test,D1, by="V1")[1:15];
meter_test_D2<- merge(meter_test,D2, by="V1")[1:15];
meter_test_D3<- merge(meter_test,D3, by="V1")[1:15];
meter_test_D4<- merge(meter_test,D4, by="V1")[1:15];

test_daily_A1<-NULL
mid<-meter_test_A1[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/ length(unique(A1$V1))
     test_daily_A1<-c(test_daily_A1,c)
    i=i+1;   }

test_daily_A2<-NULL
mid<-meter_test_A2[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/ length(unique(A2$V1))
    test_daily_A2<-c(test_daily_A2,c)
    i=i+1;   }

test_daily_A3<-NULL
mid<-meter_test_A3[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(A3$V1))
    test_daily_A3<-c(test_daily_A3,c)
    i=i+1;   }

test_daily_A4<-NULL
mid<-meter_test_A4[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(A4$V1))
    test_daily_A4<-c(test_daily_A4,c)
    i=i+1;   }

test_daily_B1<-NULL
mid<-meter_test_B1[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(B1$V1))
    test_daily_B1<-c(test_daily_B1,c)
    i=i+1;   }

test_daily_B2<-NULL
mid<-meter_test_B2[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(B2$V1))
    test_daily_B2<-c(test_daily_B2,c)
    i=i+1;   }

test_daily_B3<-NULL
mid<-meter_test_B3[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(B3$V1))
    test_daily_B3<-c(test_daily_B3,c)
    i=i+1;   }

test_daily_B4<-NULL
mid<-meter_test_B4[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(B4$V1))
    test_daily_B4<-c(test_daily_B4,c)
    i=i+1;   }

test_daily_C1<-NULL
mid<-meter_test_C1[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(C1$V1))
    test_daily_C1<-c(test_daily_C1,c)
    i=i+1;   }

test_daily_C2<-NULL
mid<-meter_test_C2[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(uniqueC2$V1))
    test_daily_C2<-c(test_daily_C2,c)
    i=i+1;   }

test_daily_C3<-NULL
mid<-meter_test_C3[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(C3$V1))
    test_daily_C3<-c(test_daily_C3,c)
    i=i+1;   }

test_daily_C4<-NULL
mid<-meter_test_C4[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(C4$V1))
    test_daily_C4<-c(test_daily_C4,c)
    i=i+1;   }

test_daily_D1<-NULL
mid<-meter_test_D1[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(D1$V1))
    test_daily_D1<-c(test_daily_D1,c)
    i=i+1;   }

test_daily_D2<-NULL
mid<-meter_test_D2[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(D2$V1))
    test_daily_D2<-c(test_daily_D2,c)
    i=i+1;   }

test_daily_D3<-NULL
mid<-meter_test_D3[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(D3$V1))
    test_daily_D3<-c(test_daily_D3,c)
    i=i+1;   }

test_daily_D4<-NULL
mid<-meter_test_D4[c(3,5)]
for (i in 195:730){

    a<-mid[mid$day_cer==i, ]
    b<-sum(a$kwh,na.rm=FALSE)
    c<-b/length(unique(D4$V1))
    test_daily_D4<-c(test_daily_D4,c)
    i=i+1;   }

rm(a,b,c,mid)
#write.csv(test_daily_A2, file="C:/Users/ww89/test_daily_A2.csv")

