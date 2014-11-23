## Course Project for Getting and Cleaning Data
## Assignment:
## -----------------------------------------------------------------------------
## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each
##    measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set
##    with the average of each variable for each activity and each subject.
## -----------------------------------------------------------------------------
## This script also takes care of downloading and extracting the dataset,
## if necessary.

library(tools) ## for MD5SUM
library(dplyr) ## for group_by, summarise, etc.
library(tidyr) ## for gather

## Main function. You can get the final output as my_tidyds <- run_analysis()
## Set the switches to get some log messages and temp datasets
run_analysis <- function (verbose=FALSE,          # prints output messages
                          readAllData=FALSE,      # also reads triaxial values
                          writeFullDataset=FALSE, # saves the full DS of step 1
                          writeShortDataset=FALSE)# saves the short DS of step 4
{
    # Set up file names: ######################################################
    
    # The URL of our dataset:
    URLO <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    
    # The dataset filename (decoded from the URL):
    DSNAME <- basename(URLdecode(URLO))
    
    # MD5SUM of the expected dataset:
    DSMD5 <- "d29710c9530a31f303801b6bc34bd895"
    
    # file which will contain the temp datasets, if writeXXXXDataset == TRUE
    # (useful for debugging)
    fulldsFile  <- "full_dataset.txt"
    shortdsFile <- "short_dataset.txt"
    
    # final output of the script:
    tidydsFile <- "tidy_dataset.txt"
    
    # directory with dataset files:
    DSDIR <- gsub('.zip$','',DSNAME)
    
    # measures names, as in the dataset code book:
    measures <- c('subject',         # ID of the subject for this observation
                  'y',               # ID of the activity
                  'X'                # time/freq values
    )
    
    if (readAllData) {
        # add further variables
        measures <- c(measures,
                      'total_acc_x',     # total acceleration on X axis
                      'total_acc_y',     # total acceleration on Y axis
                      'total_acc_z',     # total acceleration on Z axis
                      'body_acc_x',      # body  acceleration on X axis
                      'body_acc_y',      # body  acceleration on Y axis
                      'body_acc_z',      # body  acceleration on Z axis
                      'body_gyro_x',     # body  angular velocity on X axis
                      'body_gyro_y',     # body  angular velocity on Y axis
                      'body_gyro_z'      # body  angular velocity on Z axis
        )
    }
    
    names(measures) <- measures      # assign elements names
    
    # other names:
    dsfile <- c('activity_labels',   # labels of the activities
                'features'           # names of time/freq variables
    )
    
    # name the vector elements:
    names(dsfile) <- dsfile
    
    # prepend the dataset dir:
    dsfile <- sapply(dsfile, function(x) paste0(DSDIR,'/',x,'.txt'))

    # function to load observations from dataset files:    
    load_data <- function (what) {
        log(paste0("loading data for ", what, ':'))
        
        # compose measures file names:
        measures_files <- 
            sapply(measures[1:3],
                   function(x) paste0(DSDIR,'/',what,'/',x,'_',what,'.txt'))
        
        if (readAllData) {
            measures_files <- 
                c(measures_files,
                  sapply(measures[4:length(measures)],
                         function(x) paste0(DSDIR,'/',what,'/Inertial Signals/',
                                            x,'_',what,'.txt'))
                )
        }
        
        # set the element names of measure files:
        names(measures_files) <- names(measures)
        
        # read the first file and get the number of observations 
        # (this will define the number of rows of the data frame)
        v <- measures[1]
        df <- read.table(measures_files[v], header=FALSE, 
                         colClasses="numeric", col.names=v
        )
        
        # read the other files:
        for (v in measures[2:length(measures)]) {
            log (paste("getting information for <",v,">"))
            #log (measures_files[v])
          
            tbl <- read.table(measures_files[v], header=FALSE, 
                              colClasses="numeric"
            )
            
            # name the columns of tbl in the form <measure>.V<column>:
            colnames(tbl) <- sapply(colnames(tbl), function (x) paste0(v,'.',x))
            
            df <- cbind(df,tbl)      # add the just-read data:
        }
        
        invisible(df)                # return data frame
    }
    
    ## Other service functions: ###############################################
    
    # print a log message if the verbose parameter was specified:
    log <- function(message) {
        if (verbose) {
            message(message)
        }
    }
    
    # download the test dataset:
    download_archive <- function() {
        log (paste("downloading dataset from", URLO, "..."))
        download.file(url = URLO,
                      destfile = DSNAME,
                      method="curl"
        )
        
        # check the MD5 of the file just downloaded:
        log("Checking downloaded file...")
        thisMD5=md5sum(DSNAME)
        if ( thisMD5 != DSMD5 ) {
            message(paste("WARNING: The downloaded file has an MD5SUM (",
                          thisMD5, ") different from the expected (",
                          DSMD5, "). File may have been corrupted."
            ))
            # NOTE: this warning is printed in any case, not only if(verbose)
        } else {
            log("File downloaded successfully!")
        }
    }
    
    # extract the test dataset:
    extract_archive <- function() {
        # is the zipped archive already there?
        if (!file.exists(DSNAME)) {
            download_archive()
        } 
        
        # unzip the archive:
        log ("extracting dataset...")
        unzip(zipfile = DSNAME, overwrite = TRUE)
    }
    ###########################################################################
    
    # Main program: ###########################################################

    # check if the dataset is available:
    if (!file.exists(DSDIR)) {
        message("getting data ready...")
        extract_archive()
    }
    
    log("reading data...")
    if (readAllData) {
        log("(will also read additional triaxial data)")
    }
    activities<-read.table(file=dsfile["activity_labels"],header=FALSE,
                           col.names=c("activity_id","activity_label")
    )
    
    features <- read.table(file=dsfile["features"], header=FALSE,
                           col.names=c("feature_id","feature_label"),
                           stringsAsFactors=FALSE
    )

    ## read both training and test data and make one single dataset:
    full_ds <- rbind(load_data('test'),load_data('train'))
    
    ## use descriptive column names for subject, activity and features:
    colnames(full_ds)[1:(2+nrow(features))] <-
        c("subject","activity_id",features$feature_label)
    
    # was it requested to save the temporary full dataset?
    if (writeFullDataset) {
        message (paste("writing full dataset to",fulldsFile))
        write.table(full_ds, fulldsFile, row.names = FALSE)
    }
    ##
    ## --> This completes step 1: full_ds is the merged dataset
    ##
    
    ## The data in full_ds contain all the measures for each observation.
    ## We only want the measurement on mean and standard deviation for
    ## each measurement: that is, the features labelled as "<feature>-mean()"
    ## or "<freature>-std()". It is easy to identify them because of the
    ## naming: mean() and std() look like function calls.
    ## There are, however, other features whose name contains a reference to
    ## means, like "fBodyBodyGyroMag-meanFreq()" and "angle(tBodyGyroJerkMean)".
    ## It is not very clear from the assigment if also such features have
    ## to be considered. According to this thread in the discussion forum:
    ##  [ https://class.coursera.org/getdata-009/forum/thread?thread_id=58 ]
    ##    (David's Project FAQ, started by David Hood -
    ##    by the way: thanks a lot!)
    ## the interpretation is open, provided that a motivation is presented.
    ## I have decided to exclude such features because they are NOT literal
    ## means/standard deviations computed on the measurements provided, but
    ## results of weighted or averaged measurements.
    ## (see file "features_info.txt", provided with the dataset).
    ## I also think that, for the purpose of this assignment, this issue
    ## is not that relevant.
    
    log ("filtering columns")
    # get the indices of the columns to extract:
    filtered_columns <- c(1,2,               # keep subject and activity_id
                          grep('mean\\(\\)|std\\(\\)',colnames(full_ds))
    )
    
    short_ds <- full_ds[,filtered_columns]
    ##
    ## --> This completes step 2: short_ds is the dataset with desired measures
    ##

    rm(full_ds)                      # drop the big data frame, save memory

    log ("changing labels")
    # merge with activities:
    short_ds <- 
        tbl_df(merge(activities,short_ds,by="activity_id")) %>%
        rename(activity = activity_label) %>%   # change label
        mutate(activity_id = NULL)              # drop the "activity_id" column
    ##
    ## --> This completes step 3: short_ds has now descriptive activity names
    ##
    
    # make better variable names:
    colnames(short_ds) <- colnames(short_ds)             %>%
        # correct clearly mistaken variable names:
        sapply(function(x) gsub("BodyBody", "Body",x))   %>%
        # get rid of parenthesis
        sapply(function(x) gsub("mean\\(\\)", "mean",x)) %>%
        sapply(function(x) gsub("std\\(\\)", "stdev",x)) %>%
        # use slightly more explicit names
        sapply(function(x) gsub("Acc", "Accel",x))       %>%
        sapply(function(x) gsub("Mag", "Magnitude",x))   %>%
        # make the variable domain explicit
        sapply(function(x) gsub("^t", "time-",x))        %>%
        sapply(function(x) gsub("^f", "freq-",x))
    
    # was it requested to save the temporary short dataset?
    if (writeShortDataset) {
        message (paste("writing short dataset to",shortdsFile))
        write.table(short_ds, shortdsFile, row.names = FALSE)
    }
    ##
    ## --> This completes step 4: short_ds has now descriptive variable names
    ##
    
    log ("finalizing tidy dataset")
    tidy_ds <- 
        ## gather (melt) values in short_ds to go on with tidying
        # the first two columns are the "id" of the observation
        gather(short_ds, variable, value, -c(1,2))  %>%
        group_by(activity,subject,variable)         %>%
        summarise(average = mean(value))            %>%
        # ungroup, so that separate() works:
        ungroup                                     %>%
        # identify the measures not related to axis and add "-NA" at the end
        mutate(tmpcolname = gsub("(^[tf].*[^XYZ]$)", "\\1-NA",variable)) %>%
        # change "freq" to frequency
        mutate(tmpcolname = gsub("^freq-", "frequency-",tmpcolname)) %>%
        # add "domain" variable to indicate to which domain the measure refers,
        #     "funct" to help better filter between mean and stdev,
        #     "axis" to help better filter per axis
        #     "measure" to indicate the original measure
        separate(col=tmpcolname,
                 into=c("domain","measure","funct","axis"), 
                 sep="-")                           %>%
        # change the order of colums:
        select(activity,subject,variable,average,measure,axis,domain,"function"=funct) 
    
    # set the values "NA" in axis to actual <NA>
    tidy_ds$axis[tidy_ds$axis == "NA"] <- NA
    
    rm(short_ds)                     # drop the short ds, save memory        

    # save the final tidy dataset:
    message (paste("writing final tidy dataset to",tidydsFile))
        write.table(tidy_ds, tidydsFile, row.names = FALSE)
    ##
    ## --> This completes step 5: tidy_ds is a tidy dataset saved to disk
    ##
    
    invisible(tidy_ds)               # return the tidy_ds
}
