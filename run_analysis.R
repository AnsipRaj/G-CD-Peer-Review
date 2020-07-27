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
labels<-read.table('./UCI HAR Dataset/action_labels.txt')


#Adding the subject number and action columns
train_full<-cbind(action=train_act$V1,train_full)
train_full<-cbind(subject=train_sub$V1,train_full)
test_full<-cbind(action=test_act$V1,test_full)
test_full<-cbind(subject=test_sub$V1,test_full)

#Preparing the Combined Test and Train Dataset 
combined<-rbind(test_full,train_full)

#Naming the columns with the appropriate feature names
features<-features[,-1]
features<-append(features,"action",after = 0)
features<-append(features,"subject",after = 0)
names(combined)<-features

#Choosing the variables that have mean and standard deviation values
indices1<-grep("\\-mean\\(\\)",names(combined))
indices2<-grep("\\-std\\(\\)",names(combined))
meansstdindices<-append(indices1,indices2)
meansstdindices<-append(meansstdindices,c(1,2),after = 0)
combined<-combined[,meansstdindices]


#Providing Descriptive names to the activities
combined$action[combined$action == 1] <- "WALKING"
combined$action[combined$action == 2] <- "WALKING_UPSTAIRS"
combined$action[combined$action == 3] <- "WALKING_DOWNSTAIRS"
combined$action[combined$action == 4] <- "SITTING"
combined$action[combined$action == 5] <- "STANDING"
combined$action[combined$action == 6] <- "LAYING"

#Editing the Names of the variables 

names(combined)<-tolower(names(combined))
names(combined)<-gsub("-","",names(combined))
names(combined)<-gsub("^t","time",names(combined))
names(combined)<-gsub("^f","frequency",names(combined))
names(combined)<-gsub("x$","xaxis",names(combined))
names(combined)<-gsub("y$","yaxis",names(combined))
names(combined)<-gsub("z$","zaxis",names(combined))
names(combined)<-gsub("mean\\(\\)","mean",names(combined))
names(combined)<-gsub("std\\(\\)","stddeviation",names(combined))
names(combined)<-gsub("acc","accelerometer",names(combined))
names(combined)<-gsub("gyro","gyroscope",names(combined))
names(combined)<-gsub("mag","magnitude",names(combined))
names(combined)<-gsub("bodybody","body",names(combined))

#Sorting the dataset according to the Subject
combined<-arrange(combined,subject)

#Preparing a copy to create the second dataset
secondclean<-combined

#Melting and Recasting the data with the mean for each subject and each action
names<-names(secondclean)
names<-names[-1:-2]
secondclean<-melt(secondclean,id=c("subject","action"),measure.vars = names)
seconddatasetwithmeans<-dcast(secondclean,subject + action ~ variable,mean)

#Writing the output datasets 
write.table(combined,file = "firstset.txt", row.name = FALSE)
write.table(seconddatasetwithmeans,file = "tidyset.txt", row.name = FALSE)



