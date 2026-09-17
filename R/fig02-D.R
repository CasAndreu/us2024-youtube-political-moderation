#===============================================================================
# fig02-D.R
# Title:    Little evidence of ideological bias in YouTube suspensions of 
#             political content during the 2024 US Election
# Purpose:  Code to replicate Figure 2.D in the paper, showing proportion of
#             hateful and misinformation videos that have (not) been suspended
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
# - calculate prop of hateful videos not v. suspended
hate_susp <- videos %>%
  filter(politics_bin == 1) %>%
  filter(!is.na(hateful_bin)) %>%
  group_by(hateful_bin) %>%
  summarise(n = n(),
            susp_n = sum(video_susp)) %>%
  mutate(prop = round(susp_n / n, 4),
         hateful_bin = recode(hateful_bin, 
                          `0` = "No",
                          `1` = "Yes")) %>%
  rename(target = hateful_bin) %>%
  mutate(perc = prop * 100,
         facet_label = "Hateful")

# - calculate prop of misinfo videos not v. suspended
misinfo_susp <- videos %>%
  filter(politics_bin == 1) %>%
  filter(!is.na(misinfo_bin)) %>%
  group_by(misinfo_bin) %>%
  summarise(n = n(),
            susp_n = sum(video_susp)) %>%
  mutate(prop = round(susp_n / n, 4),
         misinfo_bin = recode(misinfo_bin, 
                          `0` = "No",
                          `1` = "Yes")) %>%
  rename(target = misinfo_bin) %>%
  mutate(perc = prop * 100,
         facet_label = "Misinformation")

hate_misinfo_susp <- rbind(hate_susp, misinfo_susp)

jpeg("./plots/fig02-D.jpeg", width = 1500, height = 1200, res=225)
ggplot(hate_misinfo_susp,
       aes(x = target, y = perc)) +
  geom_bar(stat = "identity", aes(fill = target), alpha = 0.6) +
  geom_text(aes(x = target, y = perc + 0.3, label = paste0(perc, "%")), 
            size = 5,
            family = "Roboto Condensed") +
  scale_y_continuous("% removed",
                     expand = c(0,0), limits = c(0, 9)) +
  scale_x_discrete("") +
  scale_fill_manual("", values = c("gray80", "gray30")) +
  facet_nested(~ facet_label) +
  #theme_ipsum_rc() +
  theme(#--- THIS COSEMTIC SETTINGS ARE ONLY FOR THE REPLICATION MATERIAL ---#
        #--- TO AVOID ISSUES WITH FONT DEPENDENCIES -------------------------#
        panel.background = element_blank(),
        strip.background = element_blank(),
        #--------------------------------------------------------------------#panel.grid.major.x = element_blank(),
        panel.grid.major.x = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none",
        strip.text = element_text(size = 18, hjust = 0.5),
        #axis.text.x = element_text(angle = 30, vjust = 1, hjust=1, size = 10),
        axis.text.x = element_text(size = 16),
        axis.title.y = element_text(size = 14),
        panel.spacing = unit(4, "lines"))
dev.off()
