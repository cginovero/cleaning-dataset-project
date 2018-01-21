filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresMeanStd <- grep(".*mean.*|.*std.*", features[,2])
features_MeanStd <- features[featuresMeanStd,2]
features_MeanStd = gsub('-mean', 'Mean', features_MeanStd)
features_MeanStd = gsub('-std', 'Std', features_MeanStd)
features_MeanStd <- gsub('[-()]', '', features_MeanStd)


# Load the datasets
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresMeanStd]
trainActData <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjData <- read.table("UCI HAR Dataset/train/subject_train.txt")
train_cbind <- cbind(trainSubjData, trainActData, trainData)

testData <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresMeanStd]
testActData <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjData <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_cbind <- cbind(testSubjData, testActData, testData)

# merge datasets and add labels
allDataSet <- rbind(train_cbind, test_cbind)
colnames(allDataSet) <- c("subject", "activity", features_MeanStd)




# turn activities & subjects into factors

allDataSet$activity <- factor(allDataSet$activity, levels = actLabels[,1], labels = actLabels[,2])
allDataSet$subject <- as.factor(allDataSet$subject)

##Install reshape2 Package##

install.packages("reshape2")
library(reshape2)

allDataSet_melt <- melt(allDataSet, id = c("subject", "activity"))
allDataSet_mean <- dcast(allDataSet_melt, subject + activity ~ variable, mean)

#Writing tidy.txt

write.table(allDataSet_mean, "tidy.txt", row.names = FALSE, quote = FALSE)