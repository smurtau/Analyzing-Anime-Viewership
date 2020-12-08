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

#Read in large data set with fread in the data.table package
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
sd(drop_data_final$my_watched_episodes)
N <- nrow(drop_data_final)
N_greater_3 <- nrow(subset(drop_data_final,my_watched_episodes >= 3))
N_greater_3/N
#write out data
write.csv(drop_data_final,"~/Desktop/Portfolio Projects/Anime/Drop_Data.csv")

#Visualizations with ggplot package
install.packages("ggplot2")
library(ggplot2)

#bar chart to show where people are dropping, with what percentage of 
#people had a median drop value at that episode number displayed above the bar.
graph_data <- subset(drop_data_final, my_watched_episodes <= 10)

ggplot(graph_data,aes(x=my_watched_episodes,label = scales::percent(prop.table(stat(count))))) + geom_bar(position="dodge",fill="red") + 
              geom_text(stat = 'count',position = position_dodge(.9),vjust=-0.5,size=3) +
              scale_y_continuous() + labs(x = "episodes", y = "count") +
              scale_x_continuous(breaks=seq(1,10,by = 0.5))

