library(httr)
library(rvest)
library(dplyr)
library(stringr)
library(magrittr)

old_new_addr <- function (df) {
  df <- df
  func <- function(i) {
    df <- df[i, ]
    url <- sprintf("http://houseno.civil.taipei/ASP_FRONT_END/main_.asp?ttrstyle=1&yy=&mm=&dd=&s_yy=&s_mm=&s_dd=&e_yy=&e_mm=&e_dd=&ttrarea=&ttrstreet=%s&ttrsection=%s&ttrshi=%s&ttrlo=%s&ttrtemp=&ttrnum=%s&ttrfloor=&ttrg=&ttryear=&ttrmonth=&ttrday=&ettryear=&ettrmonth=&ettrday=",
                   df$ttrstreet, df$ttrsection, df$ttrshi, df$ttrlo, df$ttrnum)
    table <- GET(url)
    if(table$status_code == 200){
      table %<>% content("parsed") %>% html_node("table") %>% html_table
    } else {
      df$new_addr <- ""
      return(df)
    }

    if(!any(grepl("無相關門牌歷史資料", table$X1))){
      table_name <- table[grep("日.期", table$X1), ] %>% unlist %>% str_replace_all("\\s", "")
      start <- grep("日.期", table$X1) + 1
      end <- nrow(table) - 1
      table <- table[start:end, ]
      names(table) <- table_name
      table$日期 <- as.numeric(table$日期)
      table %<>% arrange(desc(日期))
      df$new_addr <- table[1, 3] %>% str_replace("[^\\s]+\\s", "") %>% str_trim
      print(i)
      return(df)
    }
  }

  no_cores <- detectCores()
  cl <- makeCluster(no_cores, outfile = "")
  registerDoParallel(cl)

  test <- function (i) {
    foreach(i = 1:nrow(df),
            .combine = rbind,
            .export = c("df", "func"),
            .packages = c("rvest", "httr", "magrittr", "dplyr", "stringr"))  %dopar%
      func(i)
  }

  result <- test()
  stopCluster(cl)
  return(result)
}
