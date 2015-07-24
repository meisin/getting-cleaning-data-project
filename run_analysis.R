library(data.table)

##Download and unzip file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "Datafiles.zip", method = "curl")
unzip("Datafiles.zip")

## read test data
testData <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
testData_act <- read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
testData_sub <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
## read training data
trainData <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
trainData_act <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
trainData_sub <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)

## Read Activities file anD Features file.
activities <- read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE,colClasses="character")
features <- read.table("./UCI HAR Dataset/features.txt",header=FALSE,colClasses="character")

##Assign Test and Training Data column names from Features.txxt
colnames(testData) <- features$V2
colnames(trainData) <- features$V2
colnames(testData_act) <- c("Activity")
colnames(trainData_act) <- c("Activity")
colnames(testData_sub) <- c("Subject")
colnames(trainData_sub) <- c("Subject")


### merge Test, Activity and Subject data into a dataset, including the activities
testData<-cbind(testData,testData_act)
testData<-cbind(testData,testData_sub)

### merge Training, Activity and Subject data into a dataset, including the activities
trainData<-cbind(trainData,trainData_act)
trainData<-cbind(trainData,trainData_sub)

##1. combine both test and training data
allData<-rbind(testData,trainData)

rm(testData)
rm(trainData)
rm(testData_act)
rm(testData_sub)
rm(trainData_act)
rm(trainData_sub)

##2. Extracts only the measurements on the mean and standard deviation for each measurement. 
allData <- allData[ , grepl(".*mean\\(\\)|.*std\\(\\)|Activity|Subject", colnames(allData))]

##3. Use descriptive activity names to name the activities in the data set
allData$Activity <- activities[allData$Activity, 2]

##4. Appropriately labels the data set with descriptive variable names. 
names(allData) <- gsub("-mean()", names(allData), replacement=" Mean", fixed=TRUE)
names(allData) <- gsub("-std()", names(allData), replacement=" Std", fixed=TRUE)

##5. creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidyData = aggregate(allData, by=list(Activity = allData$Activity, Subject=allData$Subject), mean)
rm(allData)

write.table(tidyData[, 1:68], "tidy.txt", sep="\t", row.name=FALSE)
