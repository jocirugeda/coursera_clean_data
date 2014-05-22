coursera_clean_data
===================

Getting and Cleaning Data Coursera - Course Project


1-  Processing of feature file
------------------------------

* Correction and tokenizing of all the features, to obtain valid column names, also to improve the meaning of the names. 

For this job is used the functions:
        *tokenize_col_name*  ( parse the original names, and change to be more coherent )       
        *normalize_feature_names* ( process all the feature names, and ensure that are valid names)

* Write a file *new_feature_names.csv* , in this file are the old and the new column names for comparison
        
* Obtain list of columns related to mean or Std of features. The selected features were those that contains  mean() , meanFreq() , std() in the original feature file. For this is used the function *filter_col_index*


2- Create dataset from test files ( with the function *label_extract_data* )
--------------------------------------------------------------------------
* load subject,activities, features files , label the columns names for all data
* extract feature columns related to mean or Std
* cbin subject , activities and extracted features

3- Create dataset from train files ( with the function *label_extract_data* )
---------------------------------------------------------------------------
* load subject,activities, features files , label the columns names for all data
* extract feature columns related to mean or Std
* cbin subject , activities and extracted features

4- Merge test and train dataset
-------------------------------
5- Include activity names as new column for the global dataset
--------------------------------------------------------------
* Load activity file
* Merge dataset by common column

6- Split dataset taking as factor two column : activity name and subject
------------------------------------------------------------------------
* Generate a new factor column in the dataset concatenating activity name and subject

* Extract a copy of the columns [activity name , subject , factor] ( for latter use), one row per factor level (unique row values)

* Delete from the dataset the columns: activity name and subject

* Split dataset of dataset by factor value

7- Compute means by factor level using lapply and function *get_mean* and obtain dataset
----------------------------------------------------------------------------------------
* Transform list of means to a data frame

* Transform data frame to matrix

* Traspose matrix

* Convert trasposed matrix to data frame

8- Include subject + activity names and write tidy dataset file
---------------------------------------------------------------
* Create new column from row.names in resulting data frame

* Use data frame of factor [activity name , subject , factor] and merge with data frame 

After merge, in the resulting dataframe there are again the columns activity name and subject

* Delete factor column from dataset

* Write file with the tidy dataset



        
