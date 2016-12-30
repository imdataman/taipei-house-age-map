library(rvest)
library(httr)
library(jsonlite)
library(magrittr)
library(foreach)
library(doParallel)

geocode <- function(df) {
  df <- df
  url <- "http://luz.tcd.gov.tw/WEB/ws_data.ashx?CMD=GETADDRESS"
  cookie <- "ExtentJS=13530263.542662358%2C2881599.487062044%2C18; ASP.NET_SessionId=4hltcyflpnhatubto45yntst"
  useragent <- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
  referer <- "http://luz.tcd.gov.tw/WEB/"

  func <- function(i) {
    address <- df[i, ]
    post_body <- list(VAL1 = address$value,
                      TOWN = address$town,
                      COUNTY = address$county)
    result <- POST(url, body = post_body, add_headers("Cookie"= cookie,
                                                      "User-Agent" = useragent,
                                                      "Referer" = referer)) %>%
      content("text") %>% fromJSON %>% .[["AddressList"]]
    result <- cbind(result, df[i, ])
    print(i)
    return(result)
  }

  no_cores <- detectCores()
  cl <- makeCluster(no_cores, outfile = "")
  registerDoParallel(cl)

  test <- function (i) {
    foreach(i = 1:nrow(df),
            .combine = rbind,
            .export = c("df", "url", "cookie", "useragent", "referer", "func"),
            .packages = c("rvest", "httr", "magrittr", "jsonlite"),
            .errorhandling = "remove")  %dopar%
      func(i)
  }

  result <- test()
  stopCluster(cl)
  return(result)
}
