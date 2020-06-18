library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features
activitylabel <- read.table("UCI HAR Dataset/activity_labels.txt")
actlabelonly[,2] <- as.character(activitylabel[,2])
features <- read.table("UCI HAR Dataset/features.txt")
featuresonly <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresreq <- grep(".*mean.*|.*std.*", featuresonly)
featuresreq.names <- features[featuresreq,2]
featuresreq.names = gsub('-mean', 'Mean', featuresreq.names)
featuresreq.names = gsub('-std', 'Std', featuresreq.names)
featuresreq.names <- gsub('[-()]', '', featuresreq.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresreq]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresreq]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
combo <- rbind(train, test)
colnames(combo) <- c("subject", "activity", featuresreq.names)

# turn activities & subjects into factors
combo$activity <- factor(combo$activity, levels = activitylabel[,1], labels = actlabelonly)
combo$subject <- as.factor(combo$subject)

combo.melted <- melt(combo, id = c("subject", "activity"))
combo.mean <- dcast(combo.melted, subject + activity ~ variable, mean)

write.table(combo.mean, "tidy.txt", row.names = FALSE, quote = FALSE)