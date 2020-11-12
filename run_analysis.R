
## Load the Data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./Data/Peergraded.zip",method="curl")
unzip(zipfile="./Data/Peergraded.zip",exdir="./Data")
path_rf <- file.path("./Data" , "UCI HAR Dataset")

## Read the Data
ActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
ActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)

SubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
SubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

FeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
FeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)

## Part 1: Merges the training and the test sets 
subject <- rbind(SubjectTrain, SubjectTest)
activity <- rbind(ActivityTrain, ActivityTest)
features <- rbind(FeaturesTrain, FeaturesTest)
# Name the columns
FeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
colnames(features) <- t(FeaturesNames[2])
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
Data <- cbind(features,activity,subject)
View(Data)

## Part 2: Extracts mean and SD for each measurement
# Using column name
subdataFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
selectedNames <- c(as.character(subdataFeaturesNames), "Activity", "Subject")
extractedData <- subset(Data, select = selectedNames)
View(extractedData)

## Part 3: Name the activities use descriptive activity names
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
for (i in 1:6){
  extractedData$Activity[extractedData$Activity == i] <- as.character(activityLabels[i,2])
}
head(extractedData$Activity, 30)

## Part 4: Labels the data with descriptive variable names.
names(extractedData)

# Acc can be replaced with Accelerometer
# Gyro can be replaced with Gyroscope
# BodyBody can be replaced with Body
# Mag can be replaced with Magnitude
# Character f can be replaced with Frequency
# Character t can be replaced with Time

names(extractedData)<-gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData)<-gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData)<-gsub("BodyBody", "Body", names(extractedData))
names(extractedData)<-gsub("Mag", "Magnitude", names(extractedData))
names(extractedData)<-gsub("^t", "Time", names(extractedData))
names(extractedData)<-gsub("^f", "Frequency", names(extractedData))
names(extractedData)<-gsub("tBody", "TimeBody", names(extractedData))
names(extractedData)<-gsub("-mean()", "Mean", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-std()", "SD", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-freq()", "Frequency", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("angle", "Angle", names(extractedData))
names(extractedData)<-gsub("gravity", "Gravity", names(extractedData))

names(extractedData)

## Part 5:  Creates a data set with the average of each.
tidyData <- aggregate(. ~Subject + Activity, extractedData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)

