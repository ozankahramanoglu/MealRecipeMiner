
# set working directory and import packages -------------------------------

library(httr)
library(rvest)
library(stringr)

setwd("E:\\SofttechInovasyon")


# Start Scraping ----------------------------------------------------------


rawUrl <- "https://www.lezzet.com.tr"
url <- paste0("https://www.lezzet.com.tr/yemek-tarifleri/corbalar/corba-tarifleri")
webpage <- read_html(url)

meals <- webpage %>% html_nodes("*") %>%                        
  html_nodes(xpath = "./a") %>%
  html_attr("href")


for (i in 1:length(meals)){
  if (is.na(str_match(meals[i],"/yemek-tarifleri/")[1])){
   meals[i] <- NA
  }
}

cleanMeals <- Filter(Negate(anyNA), meals)
cleanMeals <-  unique(cleanMeals)
meals <- cleanMeals
rm(cleanMeals)

for (i in 1:length(meals)){
  if (is.na(str_match(meals[i],"sayfa")[1])){
    print(meals[i])
  }
  else{
    meals[i] <- NA
  }
}

cleanMeals <- Filter(Negate(anyNA), meals)
cleanMeals <-  unique(cleanMeals)
meals <- cleanMeals
rm(cleanMeals)

for (i in 1:length(meals)){
  if (stringr::str_count(meals[i],"/") < 3){
    meals[i] <- NA
  }
}

cleanMeals <- Filter(Negate(anyNA), meals)
cleanMeals <-  unique(cleanMeals)
meals <- cleanMeals
rm(cleanMeals)

onlymeal <- c()

for (i in 1:length(meals)){
  if (stringr::str_count(meals[i],"/") == 4){
    onlymeal <- c(onlymeal, meals[i])
    meals[i] <- NA
  }
}

cleanMeals <- Filter(Negate(anyNA), meals)
cleanMeals <-  unique(cleanMeals)
meals <- cleanMeals
rm(cleanMeals)

meals
onlymeal
allMealslinks <- c()
mealpages <- c()

# Get all pages and write to file -----------------------------------------

for (meal in meals){
  url <- paste0(rawUrl , meal)
  webpage <- read_html(url)
 
  mealLink <- webpage %>% html_nodes("*") %>%                        
    html_nodes(xpath = "./a") %>%
    html_attr("href")
  
  for (i in 1:length(mealLink)){
    if (is.na(str_match(mealLink[i],"sayfa")[1])){
      mealLink[i] <- NA
    }
  }
  cleanMeals <- Filter(Negate(anyNA), mealLink)
  cleanMeals <-  unique(cleanMeals)
  mealLink <- cleanMeals
  rm(cleanMeals)
  mealLink

  numberOfPages <- 1
  if (length(mealLink) > 0) {
    for (i in length(mealLink)){
      number <- str_replace_all(substring(mealLink[i],nchar(mealLink[i])-1,nchar(mealLink[i])),"=","")
      if (number > numberOfPages) {
        numberOfPages <- number
      }
    }
  }
  categorizedMealLinkis <- c()
  for (i in 1:numberOfPages){
    categorizedMealLinkis <- c()
    
    url <- paste0(rawUrl,meal,"?sayfa=",i)
    webpage <- read_html(url)
    
    fileConn<-file("output.txt")
    cat(url,file = "output.txt",sep = "\n",append = TRUE)
    print(url)
    close(fileConn)
  }
}
