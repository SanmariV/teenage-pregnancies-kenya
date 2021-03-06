library(tidyverse)


init_data <- read_csv("data/Teenage Pregnancies Data 2016 to 2020_WardLevel_Quarterly.csv")

# How many adolescent pregnancies per district from 2016 - 2020
annual_preg <- init_data %>% 
  select(periodid, orgunitlevel2, 
         `adolescents (10-14 years) with  pregnancy`,
         `adolescents (15-19 years) with  pregnancy`) %>% 
  drop_na() %>% 
  glimpse()

which(is.na(annual_preg$`adolescents (15-19 years) with  pregnancy`))

annual_preg_1 <- annual_preg %>% 
  mutate(year = substring(periodid,1,4)) %>% 
  mutate(q = substring(periodid,6,6)) %>% 
  glimpse()

annual_preg_2 <- annual_preg_1 %>% 
  mutate(year_q = paste0(year,".", q )) %>% 
  glimpse()

annual_preg_2$year_q <- as.numeric(annual_preg_2$year_q)

str(annual_preg_2)
range(annual_preg_2$year_q)

annual_preg_2 <- annual_preg_2 %>% 
  arrange(year_q) %>% 
  glimpse()

annual_preg_2 %>% distinct(orgunitlevel2) %>% 
  count()

str(annual_preg_2)

annual_preg_3 <- annual_preg_2 %>% 
  select(year_q, orgunitlevel2, `adolescents (10-14 years) with  pregnancy`,`adolescents (15-19 years) with  pregnancy`) %>%
  group_by(orgunitlevel2, year_q) %>% 
  arrange(year_q) %>%
  mutate(total = `adolescents (10-14 years) with  pregnancy`+`adolescents (15-19 years) with  pregnancy`) 

annual_preg_4 <- annual_preg_3 %>% 
  select(year_q, orgunitlevel2, total) %>% 
  rename(Year = year_q, County = orgunitlevel2)

annual_preg_5 <-
  summarise(annual_preg_4,
            total = sum(total))

summary(annual_preg_3)

summary(annual_preg_5)

#source("/Users/susanroets/Dropbox/Personal/R programming/WiGISKe/code/theme_swd.R")

library(viridis)
library(hrbrthemes)

pt1 <- annual_preg_5 %>%
  ggplot( aes(x=Year, y=total, group=County, color = County)) +
  geom_line() +
  #scale_color_manual(values = c("#69b3a2", "lightgrey")) +
  #scale_size_manual(values=c(1.5,0.2)) +
  theme(legend.position="none") +
  ggtitle("Adolescent Pregnancies in Kenya by County") +
  theme_ipsum() +
  xlab("Year") +
  ylab("Total pregnancies") +
  #geom_label( x=1990, y=55000, label="Amanda reached 3550\nbabies in 1970", size=4, color="#69b3a2") +
  theme(
    legend.position="none",
    plot.title = element_text(size=14)
  )

#facet_wrap(~district)
library(Cairo)

ggplotly(pt1)

init_data %>% distinct(orgunitlevel4) %>% 
  count()

library("ggalt")
library("tidyr")
library(bbplot)

#Prepare data
dumbbell_df <- annual_preg_5 %>%
  #  filter(Year == 2016.1 | 
  #           Year == 2020.2 |
  #           Year == 2016.1) %>%
  select(County, Year, total) %>%
  spread(Year, total) %>%
  replace_na(list(`2016.1` = 0, `2016.2` = 0,`2016.3` = 0,`2016.4` = 0,
                  `2017.1` = 0, `2017.2` = 0,`2017.3` = 0,`2017.4` = 0,
                  `2018.1` = 0, `2018.2` = 0,`2018.3` = 0,`2018.4` = 0,
                  `2019.1` = 0, `2019.2` = 0,`2019.3` = 0,`2019.4` = 0,
                  `2020.1` = 0, `2020.2` = 0)) %>% 
  mutate(gap = `2020.2` - `2016.1`) %>%
  arrange(desc(gap)) %>%
  head(47)

unique(dumbbell_df$County)

# Modification to axis test size of the bbstyle() function
use_this_style <- function(){
  font <- "Helvetica"
  ggplot2::theme(plot.title = ggplot2::element_text(family = font, 
                                                    size = 28, face = "bold", color = "#222222"), plot.subtitle = ggplot2::element_text(family = font, 
                                                                                                                                        size = 22, margin = ggplot2::margin(9, 0, 9, 0)), plot.caption = ggplot2::element_blank(), 
                 legend.position = "top", legend.text.align = 0, legend.background = ggplot2::element_blank(), 
                 legend.title = ggplot2::element_blank(), legend.key = ggplot2::element_blank(), 
                 legend.text = ggplot2::element_text(family = font, size = 18, 
                                                     color = "#222222"), axis.title = ggplot2::element_blank(), 
                 axis.text = ggplot2::element_text(family = font, size = 9, 
                                                   color = "#222222"), axis.text.x = ggplot2::element_text(margin = ggplot2::margin(5, b = 10)), axis.ticks = ggplot2::element_blank(), 
                 axis.line = ggplot2::element_blank(), panel.grid.minor = ggplot2::element_blank(), 
                 panel.grid.major.y = ggplot2::element_line(color = "#cbcbcb"), 
                 panel.grid.major.x = ggplot2::element_blank(), panel.background = ggplot2::element_blank(),strip.background = ggplot2::element_rect(fill = "white"), 
                 strip.text = ggplot2::element_text(size = 22, hjust = 0))
}

#Make plot
db_plot <- ggplot(dumbbell_df, aes(x = `2016.1`, xend = `2020.2`, y = reorder(County, gap), group = County)) + 
  geom_dumbbell(colour = "#dddddd",
                size = 1.8,
                colour_x = "#FAAB18",
                colour_xend = "#1380A1") +
  use_this_style() + 
  labs(title="Adolescent pregnancies in Kenya",
       subtitle="Rise in reported pregnancies per county, 2016-2020")

glimpse(annual_preg_3)
library(GGally)
library(ggplot2)

# ages 10 - 14
ages_10_14 <- annual_preg_3 %>% 
  select(year_q, orgunitlevel2, `adolescents (10-14 years) with  pregnancy`)

ages_10_14 <- ages_10_14 %>%
  gather("age_group", "count", 3)

# ages 15 - 19
ages_15_19 <- annual_preg_3 %>% 
  select(year_q, orgunitlevel2, `adolescents (15-19 years) with  pregnancy`)

ages_15_19 <- ages_15_19 %>%
  gather("age_group", "count", 3)

# combine ages 10-14 with ages 15-19
pregnancy_groups <- bind_rows(ages_10_14,ages_15_19) %>% 
  dplyr::group_by(orgunitlevel2) %>% 
  dplyr::arrange(year_q) %>% 
  dplyr::rename(Year = year_q, County = orgunitlevel2, Total = count, Group = age_group)

#Make plot
grouped_bars <- ggplot(pregnancy_groups, 
                       aes(x = Year, 
                           y = Total, 
                           fill = as.factor(Group))) +
  geom_bar(stat="identity", position="dodge") +
  geom_hline(yintercept = 0, size = 1, colour="#333333") +
  geom_hline(yintercept = mean(pregnancy_groups$Total), size = 1,
             lty = 2, colour = "red") +
  bbc_style() +
  scale_fill_manual(values = c("#1380A1", "#FAAB18")) +
  labs(title="We're living longer",
       subtitle = "Biggest life expectancy rise, 1967-2007") +
  facet_wrap(~ County)

min_mean_pregnancies <- pregnancy_groups[which.min(pregnancy_groups$Total),]
max_mean_pregnancies <- pregnancy_groups[which.min(pregnancy_groups$Total),]