library(xml2)
library(dplyr)
library(magrittr)

setwd("./台北市建築年齡")

get_license <- function(item) {
  id <- item[[2]]
  item <- item[[1]]
  date <- item %>% xml_find_all("發照日期") %>% xml_text
  type <- item %>% xml_find_all("建造類別") %>% xml_text
  addr <- item %>% xml_find_all("全建築地點/建築地點 | 建築地點") %>% xml_text
  if(!(identical(date, character(0)) | identical(addr, character(0)))) {
    df <- data.frame(
      id = id,
      date = date,
      type = type,
      addr = addr
    )
    print(id)
    return(df)
  }
}

get_all_license <- function(file) {
  doc <- read_xml(file)
  doc_unit <- xml_find_all(doc, "執照")
  id <- doc_unit %>% xml_attr("號碼")
  doc_unit <- Map(list, doc_unit, id)
  result <- lapply(doc_unit, get_license) %>% bind_rows
  return(result)
}

result <- lapply(list.files("使用執照", full.names = T), get_all_license) %>% bind_rows

write.csv(result, "台北市建築使用執照.csv", row.names = F)
