
# set working directory and import packages -------------------------------

library(httr)
library(rvest)
library(stringr)
library(digest)

setwd("E:\\SofttechInovasyon")


# Read File and open file for json ----------------------------------------


mealPages <- read.delim(file = "output.txt", header = FALSE, sep = "\n")

fileConn<-file("outputJson.txt")
cat("{",file = "outputJson.txt",sep = "\n",append = TRUE)
cat("\t\"meals\": {",file = "outputJson.txt",sep = "\n",append = TRUE)
for (row in mealPages$V1){

# Get meals for evey page -------------------------------------------------

  
  webpage <- read_html(row)
  individualMeal <- webpage %>% 
    html_nodes("[class='sub-category-urun-box']")  %>%                        
    html_nodes(xpath = "./a") %>%
    html_attr("href")
  print(individualMeal)
  baseUrl <- strsplit(row,"\\?")[[1]][1]
  
  for (meal in individualMeal){

# Extract Meal information ------------------------------------------------

    
    mealUrl <- strsplit(row,"/")[[1]][2]
    newUrl <- paste0(baseUrl,mealUrl,meal)
    newWebpage <- read_html(newUrl)
    
    mealTags <- newWebpage %>% 
      html_nodes("[class='page-title']")  %>%                        
      html_text()
    
    mealTags <- mealTags[3:length(mealTags)]
    mealTags <- str_remove_all(mealTags,"\n")
    
    recipeMetric <- newWebpage %>% 
      html_nodes("[class='recipe-metric']") %>%
      html_text()
    
    recipeMertricWorked <- str_split(unlist(recipeMetric),"\n")
    
    mealName <- newWebpage %>% 
      html_nodes("[class='recipe-header']") %>%
      html_text()
    
    mealName <- str_remove_all(mealName,"\n")
    mealName<-sub(".", "", mealName)
  
    ingredients <- newWebpage %>% 
      html_nodes("[class='recipe-ingredients']")%>%
      html_text()
    ingredients <- str_replace_all(ingredients,"\n"," ")
    
    details <- newWebpage %>% 
      html_nodes("[class='recipe-detail']")%>%
      html_text()
    details <- str_replace_all(details,"\n"," ")
    
    imageFile <- newWebpage %>% 
      html_nodes("[class='recipe-image']")%>%
      html_nodes(xpath = "./img") %>%
      html_attr("src")
    try(download.file(url = imageFile,destfile = paste0(getwd(),"/","images","/",str_replace_all(mealName," ","-"),".jpg"),method = "curl"))
    
    mealId <- digest::digest(mealName, "md5")
    
    cat(paste0("\t\t","\"",mealId,"\" : {"),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t\t","\"Name\" : ", mealName,"\","),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t\t","\"Metrics\" : ", recipeMertricWorked[[1]][2],":",recipeMertricWorked[[1]][3],";",
               recipeMertricWorked[[2]][2],":",recipeMertricWorked[[2]][3],";",
               recipeMertricWorked[[3]][2],":",recipeMertricWorked[[3]][3],
               "\","),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t\t","\"Tags\" : ", mealTags[1],";",mealTags[2],";",mealTags[3],"\","),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t\t","\"OriginalUrl\" : ", newUrl,"\","),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t\t","\"OriginalUrimageUrl\" : ", imageFile,"\","),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t\t","\"ingredients\" : ", ingredients,"\","),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t\t","\"details\" : ", details,"\","),file = "outputJson.txt",sep = "\n",append = TRUE)
    cat(paste0("\t\t}"),file = "outputJson.txt",sep = "\n",append = TRUE)
  }
}
cat(paste0("\t}"),file = "outputJson.txt",sep = "\n",append = TRUE)
cat(paste0("}"),file = "outputJson.txt",sep = "\n",append = TRUE)
close.connection(fileConn)


