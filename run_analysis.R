#Loading Libraries
library(dplyr)
library(reshape2)

#Downloading Raw Data 
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","raw.zip")
unzip("raw.zip")

#Reading Relevant Files into R
train_full<-read.table('./UCI HAR Dataset/train/X_train.txt')
train_sub<-read.table('./UCI HAR Dataset/train/subject_train.txt')
train_act<-read.table('./UCI HAR Dataset/train/y_train.txt')
test_full<-read.table('./UCI HAR Dataset/test/X_test.txt')
test_sub<-read.table('./UCI HAR Dataset/test/subject_test.txt')
test_act<-read.table('./UCI HAR Dataset/test/y_test.txt')
features<-read.table('./UCI HAR Dataset/features.txt')
labels<-read.table('./UCI HAR Dataset/activity_labels.txt')


#Adding the subject number and activity columns
train_full<-cbind(subjectact=train_act$V1,train_full)
train_full<-cbind(subjectname=train_sub$V1,train_full)
test_full<-cbind(subjectact=test_act$V1,test_full)
test_full<-cbind(subjectname=test_sub$V1,test_full)

#Preparing the Combined Test and Train Dataset 
combined<-rbind(test_full,train_full)

#Naming the columns with the appropriate feature names
features<-features[,-1]
features<-append(features,"subjectact",after = 0)
features<-append(features,"subjectname",after = 0)
names(combined)<-features

#Choosing the variables that have mean and standard deviation values
indices1<-grep("mean()",names(combined))
indices2<-grep("std()",names(combined))
meansstdindices<-append(indices1,indices2)
meansstdindices<-append(meansstdindices,c(1,2),after = 0)
combined<-combined[,meansstdindices]
names(combined)<-gsub("-","",names(combined))

#Providing Descriptive names to the activities
combined$subjectact[combined$subjectact == 1] <- "WALKING"
combined$subjectact[combined$subjectact == 2] <- "WALKING_UPSTAIRS"
combined$subjectact[combined$subjectact == 3] <- "WALKING_DOWNSTAIRS"
combined$subjectact[combined$subjectact == 4] <- "SITTING"
combined$subjectact[combined$subjectact == 5] <- "STANDING"
combined$subjectact[combined$subjectact == 6] <- "LAYING"

#Sorting the dataset according to the Subject
combined<-arrange(combined,subjectname)

#Preparing a copy to create the second dataset
secondclean<-combined

#Melting and Recasting the data with the mean for each subject and each activity
names<-names(secondclean)
names<-names[-1:-2]
secondclean<-melt(secondclean,id=c("subjectname","subjectact"),measure.vars = names)
seconddatasetwithmeans<-dcast(secondclean,subjectname + subjectact ~ variable,mean)

#Writing the output datasets 
write.table(combined,file = "firstset.txt", row.name = FALSE)
write.table(seconddatasetwithmeans,file = "secondset.txt", row.name = FALSE)


