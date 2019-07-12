# You should create one R script called run_analysis.R that does the following.

# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Install packages
install.packages('data.table')
install.packages('reshape2')

# Load packages
library('data.table')
library('reshape2')

#import labels and features
labels <- fread(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt"), col.names = c("label", "activity"))
features <- fread(file.path(getwd(), "UCI HAR Dataset/features.txt"), col.names=c("index", "name"))
features_filtered <- grep("(mean|std)\\(\\)", features[, name])
measurements <- features[features_filtered, name]
measurements <- gsub('[()]', '', measurements)

# Import train and test data
train <- fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[, features_filtered, with = FALSE]
test <- fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[, features_filtered, with=FALSE]
data.table::setnames(train, colnames(train), measurements)
data.table::setnames(test, colnames(test), measurements)
train_activities <- fread(file.path(getwd(), "UCI HAR Dataset/train/Y_train.txt"), col.names = c("activity"))
test_activities <- fread(file.path(getwd(), "UCI HAR Dataset/test/Y_test.txt"), col.names = c('activity'))
train_subjects <- fread(file.path(getwd(), "UCI HAR Dataset/train/subject_train.txt"), col.names = c('subject_id'))
test_subjects <- fread(file.path(getwd(), "UCI HAR Dataset/test/subject_test.txt"), col.names = c('subject_id'))
train <- cbind(train_subjects, train_activities, train)
test <- cbind(test_subjects, test_activities, test)

# Merge test and train
full_data <- rbind(train, test)

# Put better comment here
full_data[['activity']] <- factor(full_data[, activity], levels=labels[["label"]], labels=labels[["activity"]])
full_data[["subject_id"]] <- as.factor(full_data[, subject_id])
full_data <- reshape2::melt(data = full_data, id=c("subject_id", "activity"))
full_data <- reshape2::dcast(data=full_data, subject_id+activity~variable, fun.aggregate=mean)

data.table::fwrite(x=full_data, file="tidyData.txt", quote=FALSE)