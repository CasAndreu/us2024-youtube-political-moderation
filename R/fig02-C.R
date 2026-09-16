#===============================================================================
# fig02-C.R
# Title:    Little evidence of ideological bias in YouTube suspensions of 
#             political content during the 2024 US Election
# Purpose:  Code to replicate Figure 2.C in the paper, showing 
#             proportion of suspended videos by ideology of the channel.
# Author:   Andreu Casas
#===============================================================================

# PACKAGES
#===============================================================================
library(dplyr)
library(ggplot2)
library(tidyr)
library(ggh4x)

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
pol_denom <- videos %>%
  group_by(politics_bin) %>%
  summarise(denom = n())

pol_ideo_db <- videos %>%
  filter(!is.na(ideo_cat02)) %>%
  group_by(ideo_cat02, politics_bin) %>%
  summarise(n = n(),
            susp_n = sum(video_susp))

pol_ideo_db02 <- left_join(pol_ideo_db, pol_denom) %>%
  mutate(prop = round(susp_n / n, 4))

pol_ideo_db03 <- rbind(
  pol_ideo_db02 %>% mutate(ideo_cat02 = recode(ideo_cat02,
                                               `neutral` = "Neutral",
                                               `liberal` = "Liberal",
                                               `conservative` = "Conservative",
                                               `moderate` = "Moderate")),
  pol_ideo_db02 %>% 
    group_by(politics_bin) %>% 
    summarise(n = sum(n), susp_n = sum(susp_n), denom = sum(denom)) %>% 
    mutate(ideo_cat02 = "ALL", prop = round(susp_n / n, 4))
) %>%
  mutate(ideo_cat02 = factor(ideo_cat02,
                             levels = c("ALL", "Neutral", "Liberal", "Moderate", "Conservative")),
         politics = ifelse(politics_bin == 1, "Political\n(Video Ideology)", "Not political"),
         susp_perc = prop * 100,
         #facet_label = "VIDEOS",
         text01 = paste0(susp_perc, "%"),
         text02 = paste0(
           "(", 
           format(susp_n, big.mark = ","), ")"))

jpeg("./plots/fig02-C.jpeg", width = 1400, height = 1200, res=225)
ggplot(pol_ideo_db03,
       aes(x = ideo_cat02, y = susp_perc)) +
  geom_bar(stat = "identity", aes(fill = ideo_cat02), alpha = 0.6) +
  geom_text(aes(x = ideo_cat02, y = susp_perc + 0.6, label = text01), 
            size = 4.5,) +
  geom_text(aes(x = ideo_cat02, y = susp_perc + 0.2, label = text02),
            size = 3.5) +
  scale_y_continuous("% removed",
                     expand = c(0,0), limits = c(0, 6.5)) +
  scale_x_discrete("") +
  scale_fill_manual("", values = c("orange2", "green4", "blue4", "gray70", "red4")) +
  facet_wrap(~politics) +
  #facet_nested(~ facet_label + politics) +
  #theme_ipsum_rc() +
  theme(#--- THIS COSEMTIC SETTINGS ARE ONLY FOR THE REPLICATION MATERIAL ---#
        #--- TO AVOID ISSUES WITH FONT DEPENDENCIES -------------------------#
        panel.background = element_blank(),
        strip.background = element_blank(),
        #--------------------------------------------------------------------#
        panel.grid.major.x = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none",
        strip.text = element_text(size = 16, hjust = 0.5),
        #axis.text.x = element_text(angle = 30, vjust = 1, hjust=1, size = 10),
        axis.text.x = element_text(size = 10),
        axis.title.y = element_text(size = 14),
        panel.spacing = unit(4, "lines"))
dev.off()
