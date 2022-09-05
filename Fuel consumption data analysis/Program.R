#Name:- KHALED AHMED DARAAN SAIF 
#TPNUMBER:-TP056950

#Data Reading
filedata_t <- read.csv("data.csv", TRUE)
#DATA SCRUBBING
colSums(is.na(filedata_t))
#removing columns which are mostly empty
filedata <- subset(filedata, select = -c(standard_12_months,standard_6_months,first_year_12_months,first_year_6_months,date_of_change))
#23 features left
#Last two columns left now are fuel cost per mile for
#12000 mile and 6000 miles but data is missing from both
# though the data of both can be compiled into one since the data missing of one 
#columns complete another column.

filedata$fuel_cost_1_mile <- ifelse(is.na(filedata$fuel_cost_12000_miles), as.double(filedata$fuel_cost_6000_miles/6000),as.double(filedata$fuel_cost_12000_miles / 12000))
#removing the 6000 miles and 12000miles columns
filedata <- subset(filedata, select = -c(fuel_cost_12000_miles,fuel_cost_6000_miles,fuel_cost_1_miles))
#removing particulates emission features since it has 
#very less data which eventually after processing on the features
#will generate noise data.
filedata <- subset(filedata, select = -c(particulates_emissions))
#similar case for nox emission
filedata <- subset(filedata, select = -c(thc_nox_emissions))
#more than 70% of tax_band data is missing hence removing tax_banda data
filedata <- subset(filedata, select = -c(tax_band))
#Since there are several different models of maker
# maker feature can be simplied by removing the name after "-"
filedata$Maker = sub("-.*","",filedata[,2])






#Analyzing FOR CHEAPER


#fuel_cost_1_mile feature data can be rounded off to 3 decimal places
filedata$fuel_cost_1_mile <- round(filedata$fuel_cost_1_mile,digits = 3)
summary(filedata)


library(dplyr)
library(ggpubr)
library(tidyverse)
library(DescTools)
library(ggplot2)


filedata %>%
  group_by(Maker) %>%
  dplyr::summarise(mean_cost = round(mean(fuel_cost_1_mile,na.rm=TRUE),3)) %>%
  filter(mean_cost < 0.105) %>%
  ggplot + aes(x=reorder(Maker, mean_cost), y = mean_cost) + geom_bar(stat ="identity", fill="lightblue") + geom_text(aes(label = mean_cost),vjust = 1.6, color = "red", size = 5)+  scale_x_discrete(guide = guide_axis(n.dodge=3))+labs(title = "FIRST ANALYSIS(MEAN FUEL COST PER MILE", x ="MAKERS", y = "Fuel cost per mile.")


#Analysis by determining which car type consume less

transmission_type = summarise_at(group_by(filedata, transmission_type), vars(urban_metric), funs(mean(.,na.rm = TRUE)))
finaltransmissiontype = transmission_type.urban_metric[2:3, ]
p <- ggplot(finaltransmissiontype, aes(x= transmission_type, y=urban_metric )) + geom_bar(stat = "identity", width= 0.7) + labs(title  = "SECOND ANALYSIS( TRANSMISSION TYPE TO URBAN METRIC)",x = "TRANSMISSION TYPE", y = "URBAN METRIC") + theme_classic2()
p
p+ coord_flip()


#Analysis by fuel type and fuel consumption
fueltype = summarise_at(group_by(filedata, fuel_type), vars(fuel_cost_1_mile), funs(mean(.,na.rm = TRUE)))
ggplot(fueltype, aes(x= reorder(fuel_type,fuel_cost_1_mile), y=fuel_cost_1_mile )) + geom_bar(stat = "identity", width= 0.3) +scale_x_discrete(guide = guide_axis(n.dodge=3)) + labs(title  = "THIRD ANALYSIS( FUEL TYPE TO FUEL COST_MILE)",x = "FUELTYPE", y = "FUEL COST PER MILE")  + theme(axis.text.x = element_text(size = 5)) 







#ANALYSIS OF LESSER NOISE POLLUTION

#Brands which are the most environmental friendly  by using noise level as parameter

noiselevel = summarise_at(group_by(filedata, Maker), vars(noise_level), funs(mean(.,na.rm = TRUE)))
p <- ggplot(noiselevel, aes(x=reorder( Maker, noise_level), y=noise_level )) + geom_bar(stat = "identity", width= 0.2) +  scale_x_discrete(guide = guide_axis(n.dodge=1))+ labs(title  = "FIRST ANALYSIS( MAKER TO NOISE LEVEL)",x = "MAKER", y = "NOISE_LEVEL") + theme_classic2()
p  
p+ coord_flip()



#BASED ON FUEL TYPE
fuel_type_enviornment = summarise_at(group_by(filedata, fuel_type), vars(noise_level), funs(mean(.,na.rm = TRUE)))
ggplot(fuel_type_enviornment, aes(x= reorder(fuel_type, noise_level), y=noise_level )) + geom_bar(stat = "identity", width= 0.2)+  scale_x_discrete(guide = guide_axis(n.dodge=2)) + labs(title  = "SECOND ANALYSIS( FUEL TYPE TO NOISE_LEVEL)",x = "FUELTYPE", y = "NOISE_LEVEL") + theme_classic2()



#BASED ON TRANSMISSION TYPE
transmission_type_noise = summarise_at(group_by(filedata, transmission_type), vars(noise_level), funs(mean(.,na.rm = TRUE)))
finaltransmissiontype_noise = transmission_type_noise[2:3, ]
p <- ggplot(finaltransmissiontype_noise, aes(x = transmission_type, y=noise_level )) + geom_bar(stat = "identity", width= 0.7) + labs(title  = "THIRD ANALYSIS( TRANSMISSION TYPE TO NOISE_LEVEL)",x = "TRANSMISSION TYPE", y = "NOISE_LEVEL") + theme_classic2()
p
p+ coord_flip()






#ANALYSIS FOR ENVIORNMENTAL FRIENDLY

##Brands analysis environmental friendly  by using CO EMISSION as parameter

co_emission_level = summarise_at(group_by(filedata, Maker), vars(co_emissions), funs(mean(.,na.rm = TRUE)))
#sorting the data
sorted_co_level = co_emission_level[
  with(co_emission_level, order(co_emissions)),
]
#plotting the data
p <- ggplot(sorted_co_level, aes(x= fct_inorder(Maker), y=co_emissions )) + geom_bar(stat = "identity", width= 0.1) + scale_x_discrete(guide = guide_axis(n.dodge=2)) + labs(title  = "FIRST ANALYSIS( MAKER TO CO_EMISSION_LEVEL)",x = "MAKER", y = "Co_EMISSION_LEVEL") + theme_classic2()
p
p+ coord_flip()


##Brands analysis environmental friendly  by using co2 EMISSION as parameter
co2_emission_level = summarise_at(group_by(filedata, Maker), vars(co2), funs(mean(.,na.rm = TRUE)))
#sorting the data
sorted_co2_level = co2_emission_level[
  with(co2_emission_level, order(co2)),
]
#plotting the data
p <- ggplot(sorted_co2_level, aes(x= fct_inorder(Maker), y=co2 )) + geom_bar(stat = "identity", width= 0.1) + scale_x_discrete(guide = guide_axis(n.dodge=2))+ labs(title  = "SECOND ANALYSIS( MAKER TO CO2_EMISSION_LEVEL)",x = "MAKER", y = "Co_EMISSION_LEVEL") + theme_classic2()
p
p+ coord_flip()



##Brands analysis environmental friendly  by using thc EMISSION as parameter
thc_emission_level = summarise_at(group_by(filedata, Maker), vars(thc_emissions), funs(mean(.,na.rm = TRUE)))
#sorting the data
sorted_thc_emission = thc_emission_level[
  with(thc_emission_level, order(thc_emissions)),
]
#plotting the data
p <- ggplot(sorted_thc_emission, aes(x= fct_inorder(Maker), y=thc_emissions )) + geom_bar(stat = "identity", width= 0.2) + scale_x_discrete(guide = guide_axis(n.dodge=2))+ labs(title  = "THIRD ANALYSIS( MAKER TO THC_EMISSION_LEVEL)",x = "MAKER", y = "thc_EMISSION_LEVEL") + theme_classic2()
p
p+ coord_flip()





#ANALYSIS FOR SUITABILITY TO USERS.



#Brand analysis using engine type. Checking for most powerful cars.
engine_value = summarise_at(group_by(filedata, Maker), vars(engine_capacity), funs(mean(.,na.rm = TRUE)))
#sorting the data
sorted_engine_value = engine_value[
  with(engine_value, order(engine_capacity)),
]
#plotting the data
p <- ggplot(sorted_engine_value, aes(x= fct_inorder(Maker), y=engine_capacity )) + geom_bar(stat = "identity", width= 0.2) + scale_x_discrete(guide = guide_axis(n.dodge=2))+ labs(title  = "FIRST ANALYSIS( MAKER TO Engine capacity)",x = "MAKER", y = "Engine capacity") + theme_classic2()
p
p+ coord_flip()


#WHICH BRAND HAS NUMBER OF TRANSMISSION TYPE.

Number_type = select(filedata, c('Maker','transmission_type'))
value_count  = Number_type %>% count(Maker, transmission_type)
ggplot(value_count, aes(x=Maker, y= n, fill = transmission_type))+ geom_bar(stat = "identity") + labs(title  = "SECOND ANALYSIS( COUNT PER TRANSMISSION TYPE)",x = " BRANDS", y = "Total number")+ scale_x_discrete(guide = guide_axis(n.dodge=3)) + theme_classic2()

#ANALYSIS using euro standard

standard_type = select(filedata, c('Maker','euro_standard'))
standard_count  = standard_type %>% count(Maker, euro_standard)
ggplot(standard_count, aes(x=Maker, y= n, fill = euro_standard))+ geom_bar(stat = "identity") + labs(title  = "THIRD ANALYSIS( COUNT PER TRANSMISSION TYPE)",x = "AUTOMATIC TYPE", y = "BRAND") + scale_x_discrete(guide = guide_axis(n.dodge=3))+theme_classic2()

