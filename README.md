# Analyzing-Anime-Viewership
The full data set we used for this project is available on Kaggle here, along with a full data set description: https://www.kaggle.com/azathoth42/myanimelist

Although we include the files we used in this analysis.

In this project we attempt to find out if the "3 Episode Rule" is commonly used.  Among Anime enthusiasts, the 3 epsiode rule states that a show should be watched for at least 3 episodes before you decide to stop watching it or not.

This repo consists of an R script that takes in data crawled from my anime list about both anime shows and anime viewers.
The data is cleaned and processed, and a new data set is created that contains a two fields: a username, and the median value
of episodes watched before that user drops a show.  More detail is available as comments in the R script itself.

We find that the median value for episodes watched before dropping is 3, and the average value is ~3.84, with a standard deviation of 2.8.  ~62.4% of users drop shows, on median, with >= 3 episodes watched.  This seems to suggest that the rule is commonly used.
