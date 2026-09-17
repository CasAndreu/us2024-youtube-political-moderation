#===============================================================================
# fig02-E.R
# Title:    Little evidence of ideological bias in YouTube suspensions of 
#             political content during the 2024 US Election
# Purpose:  Code to replicate Figure 2.D in the paper, showing proportion of
#             hateful and misinformation videos that have (not) been suspended,
#             by the ideological leaning of the content
# Author:   Andreu Casas
#===============================================================================

# PACKAGES
#===============================================================================
library(dplyr)
library(ggplot2)
library(tidyr)

# PATHS & CONSTANTS
#===============================================================================
data_path <- "./data/"

# DATA
#===============================================================================
# - load channel-level dataset. N = 2,325,867
videos <- read.csv(
  "../DATA-us2024-youtube-political-moderation/videos-EN-nov23-nov24.csv")

# MAIN
#===============================================================================
# - denominator for the number of (not) misinfo videos
misinfo_denom <- videos %>%
  filter(politics_bin == 1) %>%
  filter(!is.na(misinfo_bin)) %>%
  filter(ideo_cat02 != "") %>%
  group_by(misinfo_bin) %>%
  summarise(denom = n())

# - denominator for the number of (not) misinfo videos; by ideo
misinfo_ideo <- videos %>%
  filter(politics_bin == 1) %>%
  filter(!is.na(misinfo_bin)) %>%
  filter(!is.na(ideo_cat02)) %>%
  group_by(misinfo_bin, ideo_cat02) %>%
  summarise(n = n(),
            susp_n = sum(video_susp))

# - merging the two and calculating proportion/percentages
misinfo_ideo02 <- left_join(misinfo_ideo, misinfo_denom) %>%
  mutate(prop = round(n / denom, 4),
         perc = prop * 100,
         ideo_cat02 = recode(ideo_cat02, 
                       `conservative` = "Conservative",
                       `moderate` = "Moderate",
                       `neutral` = "Neutral",
                       `liberal` = "Liberal"),
         ideo = factor(ideo_cat02, levels = c("Neutral", "Liberal", "Moderate", "Conservative")),
         misinfo = recode(misinfo_bin, 
                          `0`="No",
                          `1`="Yes"),
         facet_label = "Misinformation") %>%
  rename(value = misinfo)

# - denominator for the number of (not) hateful videos
hate_denom <- videos %>%
  filter(politics_bin == 1) %>%
  filter(!is.na(hateful_bin)) %>%
  filter(!is.na(ideo_cat02)) %>%
  group_by(hateful_bin) %>%
  summarise(denom = n())

# - denominator for the number of (not) hateful videos; by ideo
hate_ideo <- videos %>%
  filter(politics_bin == 1) %>%
  filter(!is.na(hateful_bin)) %>%
  filter(!is.na(ideo_cat02)) %>%
  group_by(hateful_bin, ideo_cat02) %>%
  summarise(n = n(),
            susp_n = sum(video_susp))

# - merging the two and calculating proportion/percentages
hate_ideo02 <- left_join(hate_ideo, hate_denom) %>%
  mutate(prop = round(n / denom, 4),
         perc = prop * 100,
         ideo_cat02 = recode(ideo_cat02, 
                       `conservative` = "Conservative",
                       `moderate` = "Moderate",
                       `neutral` = "Neutral",
                       `liberal` = "Liberal"),
         ideo = factor(ideo_cat02, levels = c("Neutral", "Liberal", "Moderate", "Conservative")),
         hateful_bin = recode(hateful_bin, 
                          `0`="No",
                          `1`="Yes"),
         facet_label = "Hateful") %>%
  rename(value = hateful_bin)

# - merge the data for misinfo and hateful so that we can plot them together
#   more easily
both_ideo02 <- rbind(misinfo_ideo02, hate_ideo02) %>%
  rename(`Video Ideology` = ideo,
         Proportion = perc)

jpeg("./plots/fig02-E.jpeg", width = 1500, height = 1200, res=225)
ggplot(both_ideo02,
       aes(x = value, y = Proportion)) +
  geom_bar(stat = "identity", position = "fill",
           aes(fill = `Video Ideology`), alpha = 0.7) +
  geom_text(inherit.aes = FALSE,
            data = both_ideo02 %>% filter(`Video Ideology` == "Conservative"),
            aes(x = value, y = 0.05, label = paste0(Proportion, "%")),
            size = 4.5) +
  scale_fill_manual("", 
                    values = c("green4","blue4","gray70", "red4")) +
  scale_x_discrete("") +
  facet_wrap(~ facet_label) +
  #theme_ipsum_rc() +
  theme(#--- THIS COSEMTIC SETTINGS ARE ONLY FOR THE REPLICATION MATERIAL ---#
        #--- TO AVOID ISSUES WITH FONT DEPENDENCIES -------------------------#
        panel.background = element_blank(),
        strip.background = element_blank(),
        #--------------------------------------------------------------------#panel.grid.major.x = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.ticks = element_blank(),
        strip.text = element_text(size = 18, hjust = 0.5),
        axis.text.x = element_text(size = 16),
        axis.title.y = element_text(size = 14),
        panel.spacing = unit(4, "lines"))
dev.off()  
