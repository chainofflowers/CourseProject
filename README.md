CourseProject
=============
### Repository for the Course Project of "Getting and Cleaning Data"

## Introduction
This repository contains the work for the Course Project assignment. The goal is to produce a tidy dataset starting from the raw data of an interesting study on wearable computing: test subjects were asked to perform some activities while wearing a smartphone, and measurement related to their movements (velocity, acceleration, etc.) were collected using the smartphone sensors.

This README file is a short description of the material produced and the steps followed to complete the assignment.

## Raw data source
The raw data consist of training and test datasets for the study. The two datasets are separated.

The raw data source, as well as the full project description, is available here:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The direct link to the raw dataset is here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

## R script
The script "run_analysis.R" takes care of:

1. searching the raw data folder on current working directory, taking care of extracting it from the zip file. This latter is downloaded automatically if not found.
2. reading both training and test datasets to merge them into a single dataset (assignemnt step 1)
3. extracting only the requested measurement variables (assignment step 2)
4. joining the observation table with a "look-up" table to provide the dataset with descriptive names for the activities (assignment step 3)
5. modifying the measurement variables to let them have (slightly) more descriptive names (assignment step 4)
6. creating a new, independent tidy dataset with the average of the variable values grouped by activity and subject (assignment step 5), which is written to disk.

The script is designed to run without any parameter, as adviced in the lecture "Components of Tidy Data" (Week 1). Nevertheless, for debugging purposes and for the convenience of peer reviewers, the script allows for some "flags" to be set, which cause the script to print some additional log messages and save temporary data used during the execution. 

The flags (boolean parameters, all defaulted to FALSE) are:
* verbose           _# prints output messages_
* readAllData       _# also reads triaxial values, not needed for the assignment_
* writeFullDataset  _# saves the temporary full DS of step 1_
* writeShortDataset _# saves the temporary short DS of step 4_

This will hopefully ease the peer review process.

## Code book
The file "CodeBook.md" is the Code book for the output tidy dataset. It describes the format of the variables and their meaning.

Please note that some variables (measures) in the original datasets contain some typos, like for example the variable named "**f**___BodyBody___**AccJerkMag-mean()**", where "_BodyBody_" should actually only be "_Body_".

## Credits
During the execution of this assignment it was of great help this thread from David Hood in the Coursera forum:
https://class.coursera.org/getdata-009/forum/thread?thread_id=58

It helped a lot in clarifying some aspect of the assignment, in particular the requested variables to extract at step 2. Due credit and clarifications are given also in the source code.
