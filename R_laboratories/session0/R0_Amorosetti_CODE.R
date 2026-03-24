# R Laboratory Session 0
# Due by : March 24, 2026

# AMOROSETTI Gabriel, 2107530
# Advanced statistics for physics analysis (2025-2026)

##################################################################################

# importing libraries

library(rvest)
library(dplyr)
library(tidyverse)
library(lubridate)
library(ggplot2)

##################################################################################
# Exercise 1 : Vectors and Data Frames

# 1.

# Instead of manually filling vectors, I decided to directly retrieve the table from the webpage
wiki_page = read_html("https://en.wikipedia.org/wiki/List_of_lochs_of_Scotland") # retrieving the html webpage
loch_table = html_node(wiki_page, ".wikitable")                                  # retrieving the html table
loch_table = html_table(loch_table, fill = TRUE)                                 # converting it into a data frame

# The table needs to be cleaned as it contains columns and rows we're not interested in :
cat('\n')
print(loch_table) 

# Creating unique columns names (as we have two 'Volume', etc.. it causes issues for later operations)
names(loch_table) = make.unique((names(loch_table)))

# Removing the columns with imperial units
loch_table = select(loch_table, -c(Volume.1, Area.1, Length.1, 'Max. depth.1', 'Mean depth[6].1'))

# Renaming some columns to avoid space and other characters 
loch_table = rename(loch_table, Max_depth = 'Max. depth', Mean_depth = 'Mean depth[6]')

# Removing the row with the units
loch_table = loch_table[-1,]

# Final dataframe :
scottish.lakes = as.data.frame(loch_table)
cat('\n')
print(scottish.lakes)

##################
# 2.

# Looking for the row index of the most and least voluminous lakes, to find the corresponding lakes names
max_vol = which.max(scottish.lakes$Volume)
min_vol = which.min(scottish.lakes$Volume)
cat('\nMost and least voluminous lakes : \n', scottish.lakes$Loch[max_vol], scottish.lakes$Volume[max_vol], 'km^3\n',
                                              scottish.lakes$Loch[min_vol], scottish.lakes$Volume[min_vol], 'km^3\n')

# Looking for the row index of the lakes with largest and smallest areas, to find the corresponding lakes names
max_area = which.max(scottish.lakes$Area)
min_area = which.min(scottish.lakes$Area)
cat('\nLakes with largest and smallest areas : \n', scottish.lakes$Loch[max_area], scottish.lakes$Area[max_area], 'km^2\n',
                                                    scottish.lakes$Loch[min_area], scottish.lakes$Area[min_area], 'km^2\n')

##################
# 3.

# Ordering the data frame with respect to the lake area
scottish.lakes = scottish.lakes[order(scottish.lakes$Area),]
cat('\n')
print(scottish.lakes)

# Retrieving the last two lakes names to get the two largest ones 
two_largest = tail(scottish.lakes$Loch, n=2)
cat('\n', 'Two largest lakes are : ', two_largest, '\n')

##################
# 4.

# Summing all the element of the Area column
s = sum(as.numeric(scottish.lakes$Area))
cat('\n Total area covered by the lakes : ', s, ' km^2\n')

##################################################################################
# Exercise 2 : 100 m Athletics Records

# 1. and 2. 

# Code from the assignment instructions 
men100m_html <- read_html("http://www.alltime-athletics.com/m_100ok.htm")
men100m_html |> html_nodes(xpath = "//pre") |> html_text() -> men100m_list
men100m_tbl <- read_fwf(men100m_list)

cat('\n')
print(men100m_tbl, n= 5)
is_tibble(men100m_tbl) # Verifying that we use a tibble structure

##################
# 3.

# Removing unwanted characters and converting to a numeric double type
men100m_tbl$X2 = gsub("A", '', men100m_tbl$X2)
men100m_tbl$X2 = as.numeric(men100m_tbl$X2)
men100m_tbl$X3 = gsub("±", '', men100m_tbl$X3)
men100m_tbl$X3 = as.numeric(men100m_tbl$X3)

# Converting to a date type
men100m_tbl$X6 = as.Date(men100m_tbl$X6, format = '%d.%m.%y')
men100m_tbl$X9 = as.Date(men100m_tbl$X9, format = '%d.%m.%Y')

cat('\n')
print(men100m_tbl, n= 5)

##################
# 4.
# (a)

# Ordering with respect to the race date
men100m_tbl = men100m_tbl[order(men100m_tbl$X9),]

# Plotting the cumulative minimun of the fastest time as a function of the race dates
pdf(file = 'plot100mMENtimes.pdf') # Saving the plot as a pdf
plot(x = men100m_tbl$X9, y= cummin(men100m_tbl$X2),
     type = 's', # using step plotting style 
     lwd = 2,
     xlab = 'Race date',
     ylab = 'Fastest 100m men time (s)',
     main = 'Evolution of the fastest time as a function of the race date')
dev.off()

# (b)

# Removing NA values from the country column
men100m_tbl = men100m_tbl[!is.na(men100m_tbl$X5), ]

# Adding a column with the year of the race only 
men100m_tbl$year = year(men100m_tbl$X9)

# Grouping by year of the race and then by countries for each year group
grouping_year_country = group_by(men100m_tbl, year, X5)

# Counting how many athletes in each country group (for each year)
sum_year_country = summarise(grouping_year_country, athlethes_n = n(), .groups = "drop")

# Grouping the previous data frame by year, giving us for each year the number of athletes from each country
group_year = group_by(sum_year_country, year)

# Ordering and taking the maximum (with respect of athlethes_n) in each year group, n = 1 to keep only the highest value
final_result = slice_max(group_year, order_by = athlethes_n, n = 1)

# Representing the number of athlethes/fastest times of the most represented country for each year
ggplot(data = final_result, 
       aes(x = year, y = athlethes_n, fill = X5)) +
       geom_col() +
       labs(
        title = 'Countries with the largest number of the fastest runners each
                year (100m, Men)',
        x = 'Year',
        y = 'Number of fastest times',
        fill = "Country"
       ) +
       theme_minimal()

# Saving the plot as a pdf
ggsave(filename = 'plot100mMENcountries.pdf')

##################
# 5.

# Repeating the same analysis for the women’s 100 m races

# 1. and 2. 

# Code from the assignment instructions 
women100m_html <- read_html("https://www.alltime-athletics.com/w_100ok.htm")
women100m_html |> html_nodes(xpath = "//pre") |> html_text() -> women100m_list
women100m_tbl <- read_fwf(women100m_list)

cat('\n')
print(women100m_tbl, n= 5)
is_tibble(women100m_tbl) # Verifying that we use a tibble structure

##################
# 3.

# Removing unwanted characters and converting to a numeric double type
women100m_tbl$X2 = gsub("A", '', women100m_tbl$X2)
women100m_tbl$X2 = as.numeric(women100m_tbl$X2)
women100m_tbl$X3 = gsub("±", '', women100m_tbl$X3)
women100m_tbl$X3 = as.numeric(women100m_tbl$X3)

# Converting to a date type
women100m_tbl$X6 = as.Date(women100m_tbl$X6, format = '%d.%m.%y')
women100m_tbl$X9 = as.Date(women100m_tbl$X9, format = '%d.%m.%Y')

cat('\n')
print(women100m_tbl, n= 5)

##################
# 4.
# (a)

# Ordering with respect to the race date
women100m_tbl = women100m_tbl[order(women100m_tbl$X9),]

# Plotting the cumulative minimun of the fastest time as a function of the race dates
pdf(file = 'plot100mWOMENtimes.pdf') # Saving the plot as a pdf
plot(x = women100m_tbl$X9, y= cummin(women100m_tbl$X2),
     type = 's', # using step plotting style 
     lwd = 2,
     xlab = 'Race date',
     ylab = 'Fastest 100m women time (s)',
     main = 'Evolution of the fastest time as a function of the race date')
dev.off()

# (b)

# Removing NA values from the country column
women100m_tbl = women100m_tbl[!is.na(women100m_tbl$X5), ]

# Adding a column with the year of the race only 
women100m_tbl$year = year(women100m_tbl$X9)

# Grouping by year of the race and then by countries for each year group
grouping_year_country = group_by(women100m_tbl, year, X5)

# Counting how many athletes in each country group (for each year)
sum_year_country = summarise(grouping_year_country, athlethes_n = n(), .groups = "drop")

# Grouping the previous data frame by year, giving us for each year the number of athletes from each country
group_year = group_by(sum_year_country, year)

# Ordering and taking the maximum (with respect of athlethes_n) in each year group, n = 1 to keep only the highest value
final_result = slice_max(group_year, order_by = athlethes_n, n = 1)

# Representing the number of athlethes/fastest times of the most represented country for each year
ggplot(data = final_result, 
       aes(x = year, y = athlethes_n, fill = X5)) +
       geom_col() +
       labs(
        title = 'Countries with the largest number of the fastest runners each
                year (100m, Men)',
        x = 'Year',
        y = 'Number of fastest times',
        fill = "Country"
       ) +
       theme_minimal()

# Saving the plot as a pdf
ggsave(filename = 'plot100mWOMENcountries.pdf')

# Comparison of the men and women results on the pdf report