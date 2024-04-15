#---------------------------------------------------#
### the code was largely learnt from: https://mp.weixin.qq.com/s/xQ_jFl3kRZkSQ8NtglFYMg 
# &  https://mp.weixin.qq.com/s/cX9tlGbGiPh27l4ausTfbQ
#
# Data information description: https://datav.aliyun.com/portal/school/atlas/area_selector
# We downloaded the data and manually rename the data file from 'People's Republic of China.json' to the English name 'china.json'.
# The data is for learning and research purposes only.
#---------------------------------------------------#

pacman::p_load("readxl", "mapchina","rjson","rlist")

chinamap1 <- geojsonsf::geojson_sf('chinamap.json') 
china_name <- rjson::fromJSON(file="chinamap.json", simplify=T) 

name <- rlist::list.map(china_name$features,properties) %>%
  list.map(name) %>%
  unlist()

name <- c(name[1:34],'九段线')

ChinaMap <- chinamap1 %>% dplyr::select(-name) %>%
  dplyr::mutate(province=name)

replacements <- list("上海市" = "Shanghai", "云南省" = "Yunnan", 
                     "内蒙古自治区" = "Inner Mongolia", "北京市" = "Beijing", 
                     "台湾省" = "Taiwan", "吉林省" = "Jilin", 
                     "四川省" = "Sichuan", "天津市" = "Tianjin", 
                     "宁夏回族自治区" = "Ningxia", "安徽省" = "Anhui", 
                     "山东省" = "Shandong", "山西省" = "Shanxi", 
                     "广东省" = "Guangdong", "广西壮族自治区" = "Guangxi",
                     "新疆维吾尔自治区" = "Xinjiang",  "江苏省" = "Jiangsu", 
                     "江西省" = "Jiangxi", "河北省" = "Hebei", 
                     "河南省" = "Henan", "浙江省" = "Zhejiang", 
                     "海南省" = "Hainan", "湖北省" = "Hubei", 
                     "湖南省" = "Hunan", "澳门特别行政区" = "Macau SAR", 
                     "甘肃省" = "Gansu", "福建省" = "Fujian", 
                     "西藏自治区" = "Tibet", "贵州省" = "Guizhou", 
                     "辽宁省" = "Liaoning","重庆市" = "Chongqing", 
                     "陕西省" = "Shaanxi", "青海省" = "Qinghai", 
                     "香港特别行政区" = "Hong Kong SAR", 
                     "黑龙江省" = "Heilongjiang" )

for(i in seq_along(replacements)) {
  ChinaMap$province <- gsub(names(replacements)[i], replacements[[i]], ChinaMap$province)
}

save(ChinaMap, file = here::here("Re_Analysis_CHN2.RData"))
