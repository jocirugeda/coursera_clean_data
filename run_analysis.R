
#  Auxiliary functions

# This function extract those columns related with mean or Std Deviation of Features
# the resulting vector is used to extract only those cloumns from the dataset
filter_col_index<-function(f_table){
        x_rows<-nrow(f_table)
        
        # extract features index with mean()|std()|meanFreq() to a vector
        col_extract<-c()
        pos<-1
        for(x in 1:x_rows){
                label<-f_table[x,2]                
                flag_col<-grepl("mean()",label)
                if (flag_col==TRUE){
                        col_extract[pos] <- x
                        pos<-pos+1
                        next
                }
                flag_col<-grepl("meanFreq()",label)
                if (flag_col==TRUE){
                        col_extract[pos] <- x
                        pos<-pos+1
                        next
                }
                flag_col<-grepl("std()",label)
                if (flag_col==TRUE){
                        col_extract[pos] <- x
                        pos<-pos+1
                        next
                }
        }
        col_extract        
}


# This function help to build a coherent dictionary of features based on the contents
# of the features.txt / features_info.txt
# divides each column name with a . to help identify related column names
# Some of the identified tokens processed: 
#     Body , Gravity , Acc , Gyro , Jerk , Mag 
tokenize_col_name<-function(name_orig){      
        #  change BodyBody  for Body alone                   
        low<-sub("BodyBody","Body",name_orig)
        #  change Body  for .Body.         
        low<-sub("Body",".Body.",low)
        #  change Gravity for .Gravity.         
        low<-sub("Gravity",".Gravity.",low)         
        #  change Acc for .Acc.         
        low<-sub("Acc",".Acc.",low)
        #  change Gyro for .Gyro.
        low<-sub("Gyro",".Gyro.",low)         
        #  change Jerk  for .Jerk.
        low<-sub("Jerk",".Jerk.",low)
        #  change Mag for .Mag.         
        low<-sub("Mag",".Mag.",low)
        
        # change not valid chars to . for valid Colum Names
        
        # change "-"  to "."
        low<-gsub("[-]",".",low)
             
        # change  () for . 
        low<-gsub("[(]",".",low)
        
        low<-gsub("[)]",".",low)
        
        # change pairs of . for one 
        low<-gsub("[.]+",".",low)
        
        # if name start with . delete that .
        if (substr(low,1,1)=="."){
                low<-substr(low,2,nchar(low))
        }
        # if name ends with . delete that
        if (substr(low,nchar(low),nchar(low))=="."){
                low<-substr(low,1,nchar(low)-1)
        }                            
        # change pairs of . for one 
        low<-gsub("[.]+",".",low)        
        low
}


# This function generate a vector of proper Column values
# input table of feature
# output vector of names that verify:
#   - are valid names for Columns in a Dataset
#   - are tokenize to maximize meaning a n comparison with the rest of the Columns
normalize_feature_names<-function(f_features){
        
        z_names<-sapply(f_features[,2],tokenize_col_name)
        ok_names<-make.names(z_names,unique=TRUE)
        ok_names
        
}


# This function create one unified dataset from this inputs:
#  path to subject file (subject_XXX.txt)
#  path to activities file (y_XXX.txt)
#  path to data feature file (X_XXX.txt)
#  vector with the full list of column Names to assign to data feature file
#  vector with the indexes of de columns to extract from the feature data file
# Output:
#       data frame with the data merged from subject, activities and extracted features with valid labels 

label_extract_data<-function(subject_file,activities_file,data_file,f_features_names,col_extract){
        
        # load subject table 
        table_subjects<-read.table(subject_file)
        # create data frame
        df_subject<-data.frame(table_subjects)
        ## set Column Label
        names(df_subject)<-c("subject")
        
        # load activities table
        table_activities<-read.table(activities_file)
        # create data frame
        df_activities<-data.frame(table_activities)
        rm(table_activities)
        ## set Column Label
        names(df_activities)<-c("activity_id")
        
        # load feature table
        table_data<-read.table(data_file)
        # create data frame
        df_data<-data.frame(table_data)
        #set columns Names
        names(df_data)<-f_features_names        
        # filter  columns 
        df_filter_data<-df_data[,col_extract]
        
        ## bind by columns subjects + activities + filter columns
        data_out<-cbind(df_subject,df_activities,df_filter_data)        
        rm(df_subject)
        rm(df_activities)
        rm(df_filter_data)
        data_out
        
}

# This function takes a data frame an returns a vector with the 
# mean of each columns 
# (except the column factor_key that is deleted fron the computations)
get_mean<-function(t_data){        
        x_data<-subset(t_data,select=-factor_key)
        x_resultado<-apply(x_data,2,mean)
        x_resultado
}


##########################  MAIN Process  #####################################

## load feature names

f_features<-read.table("features.txt")

## generate  Appropriately labels from feature names

valid_feature_names<-normalize_feature_names(f_features)

f_features$label_ok<-valid_feature_names

# save new names of features to file for use as code book
write.csv(f_features, file="new_feature_names.csv", row.names=FALSE)

## create vector of features indexes to Extracts only the measurements 
## on the mean and standard deviation for each measurement.
## those that contains ( mean() , meanFreq() , std() )

col_filter_index<-filter_col_index(f_features)


# create Data Set ( Subject + Activity + Features)

## test data set ( filtering features + labeling )

test_dataset<-label_extract_data("./test/subject_test.txt","./test/y_test.txt","./test/X_test.txt",valid_feature_names,col_filter_index)

## train data set  ( filtering features + labeling )

train_dataset<-label_extract_data("./train/subject_train.txt","./train/y_train.txt","./train/X_train.txt",valid_feature_names,col_filter_index)

## merge test+train dataset 
full_dataset<-rbind(test_dataset,train_dataset)

# clean unused variables
rm(col_filter_index)
rm(valid_feature_names)
rm(f_features)
rm(test_dataset)
rm(train_dataset)


# Create new feature to label each activity with a name ( based from file activity_labels.txt )

## load activity labels
f_activity_names<-read.table("activity_labels.txt")
## set name to columns
names(f_activity_names)[1]<-"activity_id"
names(f_activity_names)[2]<-"activity_name"

# add activity_name to dataset
named_dataset<-merge(full_dataset,f_activity_names,by="activity_id")
#clean unused variables
rm(full_dataset)
rm(f_activity_names)

# create key feature to generate factor column
named_dataset$key<-paste(named_dataset$activity_name,named_dataset$subject,sep="_")

# extract unique columns values for latter use without duplicated row
tri_field_ds<-unique(subset(named_dataset,select=c(activity_name,subject,key)))

# remove not numeric columns
pre_factor_ds<-subset(named_dataset,select=c(-activity_name,-subject,-activity_id))
rm(named_dataset)
# create factor variable
key_factor<-factor(pre_factor_ds$key)

# add factor to dataset
pre_factor_ds$factor_key<-key_factor

# remove key column from dataset
pre_split_ds<-subset(pre_factor_ds,select=-key)
rm(pre_factor_ds)

# split dataset by factor 
groups<-split(pre_split_ds,key_factor)
rm(pre_split_ds)
rm(key_factor)

# compute means for factor levels
list_means<-lapply(groups,get_mean)
rm(groups)

# convert list of means to data frame
df_list_means<-as.data.frame(list_means)
rm(list_means)

# convert data frame to matrix
means_matrix<-as.matrix(df_list_means)
rm(df_list_means)

#traspose matrix
traspose_tidy<-t(means_matrix)
rm(means_matrix)

# convert back to data frame
data_tidy<-as.data.frame(traspose_tidy)
rm(traspose_tidy)

# create colum from row.names
data_tidy$key<-row.names(data_tidy)

# merge data frame with subjet+activity  by key 
merge_final_ds<-merge(tri_field_ds,data_tidy,by="key")
rm(tri_field_ds)
rm(data_tidy)

# remove key column from dataset
final_data<-subset(merge_final_ds,select=-key)
rm(merge_final_ds)

# write data frame of tidy data
write.csv(final_data, file="table-data.csv", row.names=FALSE)
rm(final_data)
