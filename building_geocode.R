library(stringr)
library(dplyr)
library(ggplot2)
source("geocode.R")
source("old_new_addr.R")
source("twd_to_wgs.R")

setwd("./台北市建築年齡")

address <- read.csv("台北市建築使用執照.csv", stringsAsFactors = F)
address$addr <- gsub("廈門街", "厦門街", address$addr)
address$addr <- gsub("公？路", "公舘路", address$addr)
address$addr <- gsub("汀洲路", "汀州路", address$addr)
address$addr <- sub("(廈門)([^街])", "厦門街\\2", address$addr)
address$addr <- gsub("和平路東", "和平東路", address$addr)
address$addr <- sub("(吉林)([^路])", "吉林路\\2", address$addr)
address$addr <- gsub("(羅斯福)([^路])", "羅斯福路\\2", address$addr)
address$addr <- gsub("內湖三段", "內湖路三段", address$addr)
address$addr <- gsub("復北興路", "復興北路", address$addr)
address$addr <- gsub("？門街", "厦門街", address$addr)
address$addr <- sub("(民生西)([^路])", "民生西路\\2", address$addr)
address$addr <- sub("(民權東)([^路])", "民權東路\\2", address$addr)
address$addr <- sub("(林森北)([^路])", "林森北路\\2", address$addr)
address$addr <- sub("(樂群二)([^路])", "樂群二路\\2", address$addr)
address$addr <- sub("(南京東)([^路])", "南京東路\\2", address$addr)
address$addr <- sub("(臨沂)([^街])", "臨沂街\\2", address$addr)
address$addr <- gsub("區台北市文山區", "區", address$addr)
address$addr <- gsub("區台北市", "區", address$addr)
address$addr <- gsub("區臺北市", "區", address$addr)
address$addr <- gsub("提頂大道", "堤頂大道", address$addr)
address$addr <- sub("(研究院)([^路])", "研究院路\\2", address$addr)
address$addr <- sub("(基湖)([^路])", "基湖路\\2", address$addr)
address$addr <- gsub("慶慶北路", "重慶北路", address$addr)
address$addr <- gsub("內湖二段", "內湖路二段", address$addr)
address$addr <- sub("(松江)([^路])", "松江路\\2", address$addr)
address$addr <- gsub("政大ㄧ街", "政大一街", address$addr)
address$addr <- gsub("褔興路", "福興路", address$addr)
address$addr <- sub("(建國北)([^路])", "建國北路\\2", address$addr)
address$addr <- gsub("舊庄街", "舊莊街", address$addr)
address$addr <- sub("(中山北)([^路])", "中山北路\\2", address$addr)
address$addr <- gsub("？化街", "迪化街", address$addr)
address$addr <- gsub("堤場頂大道", "堤頂大道", address$addr)
address$addr <- sub("(政大一)([^街])", "政大一街\\2", address$addr)
address$addr <- sub("(健康)([^路])", "健康\\2", address$addr)
address$addr <- sub("(德行東)([^路])", "德行東\\2", address$addr)
address$addr <- gsub("景豊街", "景豐街", address$addr)
address$addr <- gsub("梧洲街", "梧州街", address$addr)
address$addr <- gsub("文胡街", "文湖街", address$addr)
address$addr <- gsub("桓光街", "恆光街", address$addr)
address$addr <- gsub("赤？街", "赤峰街", address$addr)

address$value <- case_when(
  substr(address$addr, 6, 6) == "區" ~ str_sub(address$addr, 7, regexpr("號", address$addr)),
  TRUE ~ str_sub(address$addr, 4, regexpr("號", address$addr))
)
address$town <- case_when(
  substr(address$addr, 6, 6) == "區" ~ str_sub(address$addr, 4, 6),
  TRUE ~ ""
)
address$county <- str_sub(address$addr, 1, 3)
address$date <- paste(as.numeric(str_sub(address$date, 1, -5)) + 1911,
                      str_sub(address$date, -4, -3),
                      str_sub(address$date, -2, -1),
                      sep = "-") %>% as.Date
address %<>% arrange(desc(date))

geocode(data.frame(value = "港墘里瑞光路190號", town = "", county = "台北市"))

address_unique <- address[!duplicated(address[, "value"]), ]
address_unique <- filter(address_unique, type == "新建")
# address_unique <- address_unique [!duplicated(address_unique[, "id"]), ]

address_town <- address_unique

result <- geocode(address_town)

result_failed$town <- ""

result_retry <- geocode(result_failed)

result_failed_2 <- result_failed[!result_failed$addr %in% result_retry$addr, ]

result_failed_2$ttrstreet <- case_when(
  grepl("[路街]", result_failed_2$value) ~ str_sub(result_failed_2$value, 1, regexpr("[路街]", result_failed_2$value)),
  TRUE ~ ""
)

result_failed_2$ttrsection <- case_when(
  grepl("段", result_failed_2$value) ~ str_sub(result_failed_2$value, regexpr("段", result_failed_2$value) - 1, regexpr("段", result_failed_2$value) - 1),
  TRUE ~ ""
)

result_failed_2$ttrshi <- case_when(
  grepl("巷", result_failed_2$value) ~ str_extract(str_extract(result_failed_2$value, "\\d+巷"), "\\d+"),
  TRUE ~ ""
)

result_failed_2$ttrlo <- case_when(
  grepl("弄", result_failed_2$value) ~ str_extract(str_extract(result_failed_2$value, "\\d+弄"), "\\d+"),
  TRUE ~ ""
)

result_failed_2$ttrnum <- case_when(
  grepl("號", result_failed_2$value) ~ str_extract(str_extract(result_failed_2$value, "[\\d-]+號"), "[\\d-]+"),
  TRUE ~ ""
)

result_new_addr <- old_new_addr(result_failed_2)

result_new_addr_failed <- result_failed_2[!result_failed_2$addr %in% result_new_addr$addr, ]

result_new_addr_failed$addr <- gsub("景豊街", "景豐街", result_new_addr_failed$addr)
result_new_addr_failed$addr <- gsub("梧洲街", "梧州街", result_new_addr_failed$addr)
result_new_addr_failed$addr <- gsub("文胡街", "文湖街", result_new_addr_failed$addr)
result_new_addr_failed$addr <- gsub("桓光街", "恆光街", result_new_addr_failed$addr)
result_new_addr_failed$addr <- gsub("赤？街", "赤峰街", result_new_addr_failed$addr)
result_new_addr_failed$value <- case_when(
  substr(result_new_addr_failed$addr, 6, 6) == "區" ~ str_sub(result_new_addr_failed$addr, 7, regexpr("號", result_new_addr_failed$addr)),
  TRUE ~ str_sub(result_new_addr_failed$addr, 4, regexpr("號", result_new_addr_failed$addr))
)

result_retry_2 <- geocode(result_new_addr_failed)
result_retry_2 <- result_retry_2[, 1:21]

result_new_addr_for_geocode <- result_new_addr[, c(1:7, 13)]
result_new_addr_for_geocode$value <- result_new_addr_for_geocode$new_addr
result_new_addr_for_geocode <- result_new_addr_for_geocode[, -8]

result_retry_3 <- geocode(result_new_addr_for_geocode)

result_total <- bind_rows(list(result, result_retry, result_retry_2, result_retry_3))

result_wgs <- lapply(1:nrow(result_total), function(i){
  print(i)
  twd97_to_wgs(result[i, ])
  }) %>% bind_rows

result_wgs$age <- 2016 - as.numeric(format(result_wgs$date, "%Y"))
colors <- c('#67001f','#b2182b','#d6604d','#f4a582','#fddbc7','#d1e5f0','#92c5de','#4393c3','#2166ac','#053061')
result_wgs$color <- case_when(
  result_wgs$age <= 5 ~ colors[10],
  result_wgs$age <= 10 ~ colors[9],
  result_wgs$age <= 15 ~ colors[8],
  result_wgs$age <= 20 ~ colors[7],
  result_wgs$age <= 25 ~ colors[6],
  result_wgs$age <= 30 ~ colors[5],
  result_wgs$age <= 35 ~ colors[4],
  result_wgs$age <= 40 ~ colors[3],
  result_wgs$age <= 45 ~ colors[2],
  TRUE ~ colors[1]
)

ggplot(result_wgs, aes(long, lat)) + geom_point(aes(color = color)) + coord_map()

write.csv(result_wgs, "台北市建築年份加經緯度.csv", row.names = F)
write.csv(result_wgs[, c(1:12, 22:25)] , "台北市建築年份加經緯度欄位較少版.csv", row.names = F)
