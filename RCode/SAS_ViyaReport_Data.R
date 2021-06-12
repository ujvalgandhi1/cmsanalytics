#Output for SAS Viya Reports

library(flexdashboard)
library(ggplot2)
library(data.table)
library(tidyverse)
library(plotly)
library(ggmap)
library(sqldf)

df = fread('C:/Work/CMS_RArchitecture/Data/df.csv')

p1 = sqldf("Select BENE_BIRTH_DT, Census_AgeBuckets, AdmitCategory,
           (count(distinct case when ReadmissionDays <=30 then DESYNPUF_ID end)) Readmits,
                  count(distinct DESYNPUF_ID) Inpatients,
           avg(CLM_PMT_AMT) ClaimsAmount
           from df
           where ReadmissionDays <> 'null'
           group by BENE_BIRTH_DT, Census_AgeBuckets, AdmitCategory
           ")
p1 = transform(p1, BENE_BIRTH_DT = as.Date(as.character(p1$BENE_BIRTH_DT), "%Y%m%d"))

p1$Age = as.numeric(difftime(as.Date("2021-06-09"), as.Date(p1$BENE_BIRTH_DT),
                               unit="weeks"))/52.25
p1$Age = round(p1$Age, 0)

p1 = sqldf("Select Age, Census_AgeBuckets, AdmitCategory,
           sum(Readmits) Readmits, sum(Inpatients) Inpatients, 
           avg(ClaimsAmount) ClaimsAmount
           from p1
           group by Age, Census_AgeBuckets, AdmitCategory")

write.csv(p1, 'C:/Work/CMS_RArchitecture/Data/sasviyadata/df.csv', row.names = FALSE)

#Remove all files
rm(list=ls())