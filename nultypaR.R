#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)
require(devtools)
library(plotly)


# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you 
myapp <- oauth_app(appname = "nultypaR",
                   key = "dc6dd65cd6db2df82869",
                   secret = "8589584ef75bedb19c656fe3d092ba07c54a28c4")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"]

# The above code was taken from Michael Galarnyk's webpage at:
# https://towardsdatascience.com/accessing-data-from-github-api-using-r-3633fb62cb08

# To view the data within my Github account, I must call the datat frame called 'myData'. 
# This includes public information about my account such as the repositories, acounts I follow
# and ones that follow me.
myData = fromJSON("https://api.github.com/users/nultypa")

# By using the $ sign we can view the different parts
myData$public_repos # Number of repositories
myData$followers # Number of users that follow me
myData$following # Number of users I follow

#The following data relates to repositories that I have created.

myRepositories = fromJSON("https://api.github.com/users/nultypa/repos")
myRepositories$name # The names of the repositories that I have created
myRepositories$created_at # The time and date that they were created

#The following relates to my followers

myFollowers = fromJSON("https://api.github.com/users/nultypa/followers")
myFollowers$login # Usernames of users following me on Github
myFollowers$id    # Identification number of my follower 

# The following relates to users I follow
myFollows = fromJSON("https://api.github.com/users/nultypa/following")
myFollows$login # Usernames of users I follow on Github
myFollows$id    # Identification number of users I'm following

#Viewing my classmates information ohalloa2
ohalloa2 = fromJSON("https://api.github.com/users/ohalloa2")
ohalloa2$login

#Showing all of her general information
AOH = toJSON(ohalloa2, pretty = TRUE)
AOH

asRepositories = fromJSON("https://api.github.com/users/ohalloa2/repos")
asRepositories$name   #Listing out the names of the repositories she has


##########################################################################
#Git vizulization

# I used the git account of Andrew Nesbit who currently is the second most active member of 
# github. As he is a much more active user than myself, I thought that his information would be
# be of more intrest.

andrewData = GET("https://api.github.com/users/andrew/followers?per_page=50;", gtoken)
stop_for_status(andrewData)

#Extract Andrew Nesbits information from Git
extract = content(andrewData)

#Convert infromation into a dataframe
githubDB = jsonlite::fromJSON(jsonlite::toJSON(extract))
githubDB$login

#Gather list of usernames on his account 
id = githubDB$login
user_ids = c(id)

users = c()
usersDB = data.frame(
  username = integer(),
  following = integer(),
  followers = integer(),
  repos = integer(),
  dateCreated = integer()
)

#For loop to collect all the users 
for(i in 1:length(user_ids))
{
  
  followingURL = paste("https://api.github.com/users/", user_ids[i], "/following", sep = "")
  followingRequest = GET(followingURL, gtoken)
  followingContent = content(followingRequest)
  
  if(length(followingContent) == 0)
  {
    next
  }
  
  followingDF = jsonlite::fromJSON(jsonlite::toJSON(followingContent))
  followingLogin = followingDF$login
  
  #For loopthrough Andrew Nesbits followers
  for (j in 1:length(followingLogin))
  {
    #Check if the user is already part of the list
    if (is.element(followingLogin[j], users) == FALSE)
    {
      #Adding the user to the list
      users[length(users) + 1] = followingLogin[j]
      
      #Retrive information about the user
      followingUrl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(followingUrl2, gtoken)
      followingContent2 = content(following2)
      followingDF2 = jsonlite::fromJSON(jsonlite::toJSON(followingContent2))
      
      #Number of users hes following
      followingNumber = followingDF2$following
      #Number of users following him
      followersNumber = followingDF2$followers
      #Number of repositories
      reposNumber = followingDF2$public_repos
      #Year in which the repositorie was created
      yearCreated = substr(followingDF2$created_at, start = 1, stop = 4)
      
      #Puts users data to a new row in dataframe
      usersDB[nrow(usersDB) + 1, ] = c(followingLogin[j], followingNumber, followersNumber, reposNumber, yearCreated)
    }
    next
  }
  
  #Max is 100 users 
  if(length(users) > 100)
  {
    break
  }
  next
}

#Linking R to plotly
Sys.setenv("plotly_username"="nultypa")
Sys.setenv("plotly_api_key"="RPtT79W4N9v5t77VyWcI")

plot1 = plot_ly(data = usersDB, x = ~repos, y = ~followers, 
                text = ~paste("Followers: ", followers, "<br>Repositories: ", 
                              repos, "<br>Date Created:", dateCreated), color = ~dateCreated)
plot1

api_create(plot1, filename = "Followers vs Repositories")
#URL: https://plot.ly/~nultypa/3


plot2 = plot_ly(data = usersDB, x = ~followers, y = ~following, 
                text = ~paste("Followers: ", followers, "<br>Following: ", 
                              following, "<br>Date Created:", dateCreated), color = ~dateCreated)

api_create(plot2, filename = "Following vs Followers")
#https://plot.ly/~nultypa/5



