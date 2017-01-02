# 台北市屋齡地圖
利用台北市政府開放的建築使用執照資料，製作台北市屋齡地圖

## 製作說明

製作台北市屋齡地圖的過程中，使用了R、Node、QGIS、Command Line等工具，以下根據製作過程先後，說明repo內檔案的功能：

- 使用執照：從[台北市開放資料網站](http://data.taipei/opendata/datalist/datasetMeta?oid=c876ff02-af2e-4eb8-bd33-d444f5052733)下載的原始資料
- taipei_build_license_xml.R：由於原始資料是不容易處理的XML檔，先使用R將不同年份的XML資料整合成一個檔案，並將整理好的結果輸出成`台北市建築使用執照.csv`。
- 台北市建築使用執照.csv：`taipei_build_license_xml.R`的產出。
- building_geocode.R：讀取`台北市建築使用執照.csv`，進行近一步的處理，包括地址轉經緯度、計算屋齡、舊地址轉新地址等。整理好的結果輸出成`台北市建築年份加經緯度.csv`及`台北市建築年份加經緯度欄位較少版.csv`。
- geocode.R：專門為了地址轉經緯度寫的爬蟲程式，使用[國土規劃地理資訊圖台](http://luz.tcd.gov.tw/WEB/)的全國門牌地址搜尋功能。
- twd_to_wgs.R：由於`geocode.R`產生的經緯度為TWD97格式，需要轉換成WGS84格式，才能與openstreetmap的地圖做搭配，因此寫了`twd_to_wgs.R`進行轉換，轉換公式主要參考網路上TWD97轉WGS84的文章。
- old_new_addr.R：專門為舊地址轉新地址寫的爬蟲程式，使用[台北市政府民政局門牌整合檢索系統](http://houseno.civil.taipei/)的門牌變動查詢功能。
- geoproject.ssh：我將`台北市建築年份加經緯度欄位較少版.csv`丟到QGIS，將csv轉成shp之後，用Command Line的指令（主要使用Mike Bostock的NPM module[shapefile](https://github.com/mbostock/shapefile)和d3），把shp轉成geojson，並預先做好做好座標轉換，減少瀏覽器的計算負荷，產出的結果為`tp-projection.json`。
- tp-projection.json：`geoproject.ssh`的產出結果
- split_json.js：由於一口氣繪製全台北市的建築，對瀏覽器的負擔還是太高，因此我用Nodejs讀取`tp-projection.json`，將單一檔案根據行政區切成12個檔案，放到data資料夾。
- data：存放實際用來畫地圖的12個行政區建築屋齡資料，內有12個geojson檔。
- index.html：網頁呈現的檔案，內有地圖的html、css和javascript。
