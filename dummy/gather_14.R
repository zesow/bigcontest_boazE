library(stringr)
file_names <- list.files("/Users/yumunsang/Documents/2018summer/boaz/bigcontest_boazE/movie2")
head(file_names)

i<-1
new_file_names <- NULL
for (i in 1:length(file_names)){
  #charactor의 개수
  nchar(file_names[i])
  #file_name
  name <- substr(file_names[i], 0, nchar(file_names[i])-4)
  new_file_names <- append(new_file_names, name)
}

new_file_names
file_names

setwd("/Users/yumunsang/Documents/2018summer/boaz/bigcontest_boazE/movie2")

total_data <- NULL
for (i in 1:length(file_names)){
  file <- read.csv(file_names[i], fileEncoding = "CP949",  header = T, stringsAsFactors = F, encoding = "UTF-8")
  file14 <- file[14,]
  file14[1,5] <- file[1,5]
  total_data <- rbind(total_data, file14)
  print(i)
}
total_data

setwd("/Users/yumunsang/Documents/2018summer/boaz/bigcontest_boazE/")
write.csv(total_data, "total_data.csv", row.names = F)
