library(rvest)
library(stringr)
library(xlsx)
library(dplyr)
getwd()
setwd("/Users/yumunsang/Documents/2018summer/boaz/bigcontest_boazE/moviefile")

# 하루씩 만 크롤링해서 다운로드하기
#사이트 주소 붙이기
url_vec <- NULL
# url 앞 부분만 뽑아내기
url <- "http://www.kobis.or.kr/kobis/business/stat/boxs/findDailyBoxOfficeList.do?loadEnd=0&searchType=excel&sSearchFrom="
s <- as.Date("2018-01-01")
e <- as.Date("2018-02-20")
# 나열하기 날짜 간격을 1로
date <- seq(from=s, to=e, by=1)

date <- as.character(date)
ch <- "&sSearchTo="


#사이트 주소 정리
for (i in 1:length(date)) {
  url1 <- paste0(url, date[i], ch, date[i])
  url_vec <- append(url_vec, url1)
}
url_df <- as.data.frame(url_vec)

j<-1
##사이트 크롤링 (다운)
for (j in 1:length(date)) {
  # 날짜만 뽑아내서 파일 이름으로 하기 위해서.
  b <- str_sub(as.character(url_df[j,1]), start=135, end=144)
  b <- paste0(b,".xls")
  a <- as.character(url_df[j,1])
  download.file(a, destfile = b, method='libcurl')
}
