#USER FOCUSED DATA ANALYSIS
#Read in the large Data set
#Filter it for only entries about dropped shows (status == 4)
#Filter for only TV Anime
#Exclude related piece of media (discount shows with prequel in their related work, i.e. discount animes that are direct sequels)
#Exclude anime with episodes over 24 

#3 Episode Rule: Don't drop a show before 3 episodes
#calculate a users median episode dropped
#Create Summary Statistics
#Create Bar charts of counts between 1-10 episodes with percentages displayed
#export data set as csv

#uncomment the next two lines and run to install packages if necessary
#install.packages("ggplot2")
#install.packages("data.table")

#Read in large data set with fread in the data.table package. This might take a few minutes depending on your machine.
library(data.table)
animu <- fread("animelists_cleaned.csv")

#strip all entries that don't deal with dropped shows
animu <- subset(animu,my_status == 4)

#create show data set to cross reference
show_data <- fread("AnimeList.csv")

#filter for only TV anime
show_data <- subset(show_data,type == "TV")
show_data <- subset(show_data,episodes <= 24)

#filter out sequel seasons from show_data to create seperate data set
show_data_prequels <- show_data[grep("Prequel",show_data$related)]
show_data <- rbind(show_data,show_data_prequels)
show_data <- show_data[!duplicated(show_data,fromLast = FALSE)&!duplicated(show_data,fromLast = TRUE),] 

#filter out all entries from main data set that do not correspond to an anime that remains in our show data set,
#by executing a merge on the anime_id variable.  This has the added benefit of adding data about the show to our final data.
#contains 683716 entries.
final_data <- merge(animu,show_data)

#filter out where watched episodes are equal to 0 or greater than 24,and get rid of useless columns (status,type) that we stripped before the merge
final_data <- subset(final_data,my_watched_episodes > 0)
final_data$status <- NULL
final_data$type <- NULL
final_data <- subset(final_data,my_watched_episodes <= 24)

#aggregate our data for episodes watched, find median
#and get rid of unused data columns
drop_data_final <- subset(final_data,select=c(username,my_watched_episodes))
drop_data_final <- aggregate(my_watched_episodes~username,data=drop_data_final,median)

#generate summary statistics 
summary(drop_data_final)

#get standard deviation
sd(drop_data_final$my_watched_episodes)

#get percent that follows the 3 episode rule
N <- nrow(drop_data_final)
N_greater_3 <- nrow(subset(drop_data_final,my_watched_episodes >= 3))
N_greater_3/N

#Visualizations with ggplot package
library(ggplot2)

#bar chart to show where people are dropping, with what percentage of 
#people had a median drop value at that episode number displayed above the bar.
graph_data <- subset(drop_data_final, my_watched_episodes <= 10)

ggplot(graph_data,aes(x=my_watched_episodes,label = scales::percent(prop.table(stat(count))))) + geom_bar(position="dodge",fill="orangered3") + 
              geom_text(stat = 'count',position = position_dodge(.9),vjust=-0.5,size=3) +
              scale_y_continuous() + labs(x = "episodes", y = "count") +
              scale_x_continuous(breaks=seq(1,10,by = 0.5))

#Calculate individual percentage of 3 episode rule following
#Filter data to when the rule was followed
library(plyr)
drop_data_grouping <- subset(final_data,select=c(username,my_watched_episodes),final_data$my_watched_episodes >= 3)

#find total number of user entries
drop_data_user_totals <- count(final_data,"username")

#find count of when people followed rule
drop_data_user_g_3 <- count(drop_data_grouping,"username")

#make column names descriptive (count defaults to calling it freq)
names(drop_data_user_totals)[2] <- "total_count"
names(drop_data_user_g_3)[2] <- "over/equal_3_count"

#merge data set, add 0's when people never followed the rule(had no entries in drop_data_g_3)
drop_data_merge <- merge(drop_data_user_totals,drop_data_user_g_3,all=TRUE)
drop_data_merge[is.na(drop_data_merge)] <- as.numeric(0)

#calculate percentage, add to data frame
drop_data_merge$percentage <- drop_data_merge$`over/equal_3_count`/drop_data_merge$total_count

#Create groups and graph labels
cat_labels <- c("0-10%","10-20%","20-30%","30-40%","40-50%","50-60%","60-70%","70-80%","80-90%","90-100%")
drop_data_merge$category <- cut(drop_data_merge$percentage,breaks=10,labels=FALSE)
drop_data_merge

#create graph
ggplot(drop_data_merge,aes(x=category,label = scales::percent(prop.table(stat(count))))) + geom_bar(position = "dodge",fill="orangered3") + 
  scale_x_continuous(breaks=seq(1,10,by=1),labels=cat_labels) +
  geom_text(stat = 'count',position = position_dodge(.9),vjust=-0.5,size=3) +
  scale_y_continuous() + labs(x = "Percent of Time Following Rule", y = "count")

#Add relevant data fields to drop_data_final for writing
drop_data_median_only <- drop_data_final
drop_data_final$total_count <- drop_data_merge$total_count
drop_data_final$greater_than_eq_3_count <- drop_data_merge$`over/equal_3_count`
drop_data_final$percentage <- drop_data_merge$percentage
drop_data_final$category <- drop_data_merge$category

#write out data. Replace the string with the desired output location of the file.
write.csv(drop_data_final,"~/Desktop/Portfolio Projects/Anime/Drop_Data.csv")
