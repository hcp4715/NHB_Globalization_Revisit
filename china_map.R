#---------------------------------------------------#
### the code was largely learnt from: https://zhuanlan.zhihu.com/p/657468813 &  https://zhuanlan.zhihu.com/p/688675766
# Data information description: https://www.webmap.cn/commres.do?method=result100W
# We downloaded the map data after signed up, applied for the standard map of China, and were approved.
# Map data were 77 zip files that cover the whole China.
# 
# Standard number: GB/T 13923-2022
# Chinese Standard Name: 1:100万公众版基础地理信息数据（2021）
# English standard name: 1:1 000 000 standard map of China
#
# GB code: 62 national administrative regions, 02 national boundaries, 01 demarcated;
# Layer: BOUL layer for administrative boundaries
# Filter: 620201 type of GB field
# Figure number: Clockwise from north to south: G51, F51, E50, D50, C50, B50, A49, B49, C49, D49, E49
#---------------------------------------------------#
sf::sf_use_s2(FALSE)
df_cn_geo_0 <- mapchina::china
df_cn_geo_1 <- mapchina::china %>%
  dplyr::filter(Code_Province %in% as.character(11:82))
df_cn_geo_1 <- df_cn_geo_1 %>%
  dplyr::group_by(Name_Province) %>%
  dplyr::summarise(geometry = st_union(geometry))
layer_cn <- c("A49.gdb", "B49.gdb", "B50.gdb",
              "C49.gdb", "C50.gdb", "D49.gdb", 
              "D50.gdb", "E49.gdb", "E50.gdb",
              "F51.gdb", "G51.gdb")
dat_map <- data.frame()
for (i in layer_cn){
  dat <- sf::read_sf(here::here("CHNWebMap",i),layer = 'BOUL')
  dat_1<- dat[which(dat$GB == 620201),c("GB","SHAPE")]
  dat_1$layer <- substr(i,1,3)
  dat_map <- rbind(dat_map,dat_1)
}

dat_map_1 <- sf::st_transform(dat_map,"WGS84")
st_geometry(dat_map_1)
summarise(dat_map_1)
dat_map_2 <- sf::st_sf(Name_Province = "十段线",
                       geometry = sf::st_sfc(dat_map_1$SHAPE), crs = "WGS84")
df_cn_geo_2 <- rbind(df_cn_geo_1,dat_map_2[,c('Name_Province',"geometry")])
island <- stringr::str_trim(as.matrix(readxl::read_excel("Standard_name_of_South_China_Sea_Islands.xlsx", col_names = TRUE)))
dat_map_3 <- data.frame()
for (i in layer_cn) {
  dat <- sf::read_sf(here::here("CHNWebMap",i), layer = "AANP")
  dat$layer <- substr(i, 1, 3)
  dat_map_3 <- rbind(dat_map_3, dat)
}
dat_map_4 <- data.frame()
for (i in 1:length(island)) {
  dat <- dat_map_3[which(dat_map_3$NAME == island[i]), ]
  dat_map_4 <- rbind(dat_map_4, dat)
}
dat_map_4 <- dat_map_4[-which(dat_map_4$CLASS == "JD"), ] # Removing waterways
dat_map_4 <- sf::st_transform(dat_map_4, "WGS84")
sf::st_geometry(dat_map_4)
summarise(dat_map_4)
dat_map_4 <- sf::st_sf(
  Name_Province = dat_map_4$NAME,
  geometry = sf::st_sfc(dat_map_4$SHAPE), crs = "WGS84"
)
dat_map_4 <- dat_map_4[c(-3, -56), ] # Remove duplicate Beidao and Dongsha Island in Fujian
ChinaMap <- rbind(df_cn_geo_2, dat_map_4[, c("Name_Province", "geometry")])
ChinaMap <- rename(ChinaMap, province = Name_Province)
replacements <- list("上海市" = "Shanghai", "云南省" = "Yunnan", "内蒙古自治区" = "Inner Mongolia", "北京市" = "Beijing", "台湾省" = "Taiwan", "吉林省" = "Jilin", "四川省" = "Sichuan", "天津市" = "Tianjin", "宁夏回族自治区" = "Ningxia", "安徽省" = "Anhui", "山东省" = "Shandong", "山西省" = "Shanxi", "广东省" = "Guangdong", "广西壮族自治区" = "Guangxi", "新疆维吾尔自治区" = "Xinjiang",  "江苏省" = "Jiangsu", "江西省" = "Jiangxi", "河北省" = "Hebei", "河南省" = "Henan", "浙江省" = "Zhejiang", "海南省" = "Hainan", "湖北省" = "Hubei", "湖南省" = "Hunan", "澳门特别行政区" = "Macau SAR", "甘肃省" = "Gansu", "福建省" = "Fujian", "西藏自治区" = "Tibet", "贵州省" = "Guizhou", "辽宁省" = "Liaoning","重庆市" = "Chongqing", "陕西省" = "Shaanxi", "青海省" = "Qinghai", "香港特别行政区" = "Hong Kong SAR", "黑龙江省" = "Heilongjiang" )

for(i in seq_along(replacements)) {
  ChinaMap$province <- gsub(names(replacements)[i], replacements[[i]], ChinaMap$province)
}

save(ChinaMap, file = here::here("Re_Analysis_CHN2.RData"))
