#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)

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

