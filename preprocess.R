library(rvest)
library(stringr)
library(xlsx)
library(dplyr)
getwd()
setwd("/Users/yumunsang/Documents/2018summer/boaz/bigcontest_boazE/moviefile")

#사이트 주소 붙이기
url_vec <- NULL
url <- "http://www.kobis.or.kr/kobis/business/stat/boxs/findDailyBoxOfficeList.do?loadEnd=0&searchType=excel&sSearchFrom="
s <- as.Date("2009-01-01")
e <- as.Date("2017-08-14")
date <- seq(from=s, to=e, by=1)
date <- as.character(date)

# xlax 불러오기
day_df <- NULL
for (i in 1:length(date)) {
  #다운 받은 파일 정리 (개봉일이 NA값인것들 처리 등등)
  read_date <- paste0(date[i], ".xlsx")
  day_list <- read.xlsx(read_date, sheetIndex = 1, encoding = 'UTF-8', rowIndex = 4:107, colClasses = "character")
  
  # 첫번째 줄 외에 모든 것
  movie_data <- day_list[-1,]
  
  # 개봉일 - 개봉일로부터 며칠 떨어져 있는지 계산할 것. 14일로 함. 개봉일로부터 14일만 모델에 넣어가지고 관객 수 예측해야함.
  # 중요함.
  movie_data[3]
  head(movie_data)
  
  # 개봉일이 없는 데이터는 그냥 지움.
  exc <- which(is.na(movie_data[3]))
  movie_data <- movie_data[-exc,]
  # 필요한 설명변수만 모음. 필요없는 컬럼 제거. feature 선택 과정.
  vec <- c(2,3,9,12,13,15,18,19,20,21,22)
  movie_data <- as.matrix(movie_data[,vec])
  movie_data <- gsub(" ", "", movie_data)
  movie_data <- as.data.frame(movie_data)
  # 칼럼이름 영어로 변경.
  colnames(movie_data) <- c("title", "release", "day_audience", "total_audience", "screen", "Nationality",
                            "distributor", "grade", "genre", "director", "actor")
  # date(날짜) 추가
  movie_data$date <- date[i]
  
  # day(개봉일로부터 얼마나 됬는지 처리) 오늘 날짜 - 개봉일 날짜
  exc1 <- NULL
  rel <- as.Date(movie_data$release)
  dat <- as.Date(movie_data$date)
  # 데이트는 뺄 수 있음
  da <- as.Date("2009-01-01")
  # 0 이면 1로 처리
  exc1 <- append(exc1, which(rel-da < 0))
  d <- dat-rel + 1
  # 시사회를 제외해줘야 함 ( 1보다 작은)
  exc1 <- append(exc1, which(d > 40 | d < 1))
  d <- d[-exc1]
  # 오버되는 것들을 빼 줌.
  movie_data <- movie_data[-exc1,]
  # 최종적으로 며칠 되었는지 표에 넣어줌.
  movie_data$day <- as.integer(d)
  
  # date를 바탕으로 요일 정하기
  # 요일 넣어주기. 토,일 처리해주기 위해서.
  movie_data$weekday <- weekdays(as.Date(movie_data$date))
  
  #휴일 정리 파일 읽어와서 휴일인지 아닌지 정리. 파일 주심. 뒤에 붙이기.
  holiday2 <- read.csv("holiday_cal.csv")
  holiday <- NULL
  for (x in 1:length(movie_data$date)) {
    r <- which(as.Date(movie_data$date[x]) == as.Date(as.matrix(holiday2[1])))
    holiday <- append(holiday, holiday2[r,2])
    holiday
  }
  movie_data$holiday <- holiday
  head(movie_data)
  
  #날마다 정리된 데이터를 붙인다. 하나로 붙임
  day_df <- rbind(day_df, movie_data)
  print(i)
}

# 붙인 데이터를 title별로 나열한다. 영화제목으로 나열.
# 누적 관객 수가 10만 이상인 영화만 빼서 저장해준다. 데이터 수랑 고려해서 몇만 이상으로 할 지 고민해보기

ex <- day_df[order(day_df$title),]

# : 문자 제거.(특수문자)
ex <- gsub(':', '', as.matrix(ex))
ex <- as.data.frame(ex)
write.csv(day_df, file="movie.csv", row.names = F)  # 정렬되지 않은 데이터
write.csv(ex, file="ex.csv", row.names = F)   #정렬된 데이터

real_data <- read.csv("ex.csv", header=T)  #다시 정렬된 데이터를 불러온다 (Factor문제 때문)
mov_title <- levels(real_data$title)   # 제목이 어떤 것이 있는지 확인
# 영화 제목별로 따로따로 저장
setwd("C:/Users/user/Desktop/09movie_data")
for (j in 1:length(mov_title)) {
  wh <- which(mov_title[j] == real_data$title)
  # 해당 제목 영화가 어디 있는지 찾아서 따로 빼 주기.
  sub_df <- real_data[wh,]
  # 시사회 관광객 수로 일일 관람객 수를 덮어씌워 줌
  sub_df[1,3] <- sub_df[1,4]
  ti <- paste0(mov_title[j], ".csv")
  
  # na가 아니고 5만명이 넘고 14이면??
  if (is.na(sub_df[35,1]) == F && sub_df[nrow(sub_df),4] >50000) {
    write.csv(sub_df, ti, row.names = F)
  }
}




#total_df <- NULL
#last_df <- NULL
#real_data <- read.csv("ex.csv", header=T)  #다시 정렬된 데이터를 불러온다 (Factor문제 때문)
#mov_title <- levels(real_data$title)   # 제목이 어떤 것이 있는지 확인
# 영화 제목별로 따로따로 저장
#setwd("C:/Users/user/Desktop/worked_data")
#for (j in 1:length(mov_title)) {
#  wh <- which(mov_title[j] == real_data$title)
#  sub_df <- real_data[wh,]
#  sub_df[1,3] <- sub_df[1,4]
#  ti <- paste0(mov_title[j], ".csv")
#  if (is.na(sub_df[35,1]) == F && sub_df[nrow(sub_df),4] >50000) {
#    total_df <- rbind(total_df, sub_df)
#    last_df <- rbind(last_df, sub_df[nrow(sub_df),])
#  }
#}
#write.csv(total_df, "전체영화모.csv", row.names = F)
#write.csv(last_df, "영화누적관객수.csv", row.names = F)


as.Date("2009-01-01")+1476