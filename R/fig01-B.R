#===============================================================================
# fig01-B.R
# Title:    Little evidence of ideological bias in YouTube suspensions of 
#             political content during the 2024 US Election
# Purpose:  Code to replicate Figure 1.B in the paper, showing channel
#             suspension rates, by channel ideology
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
# - load channel-level dataset. N = 20,334
channel_db <- read.csv(paste0(data_path, "channels.csv"))
  

# MAIN
#===============================================================================
# - calculate N and % suspensions by ideology -- using categorical ideo version 
#   to more easily communicate these descriptive findings
susp_byideo <- channel_db %>%
  group_by(ideo_cat) %>%
  summarise(n = n(),
            susp_n = sum(channel_susp)) %>%
  mutate(susp_prop = round(susp_n / n, 4))

# - add a row for overall suspension numbers/rate for ALL channels
susp_byideo02 <- rbind(
  susp_byideo,
  data.frame(ideo_cat = "ALL", 
             n = nrow(channel_db),
             susp_n = sum(channel_db$channel_susp)) %>%
    mutate(susp_prop = round(susp_n / n, 4))
) %>%
  mutate(ideo_cat = factor(ideo_cat,
                           levels = c(
                             "ALL", "Liberal", "Moderate", "Conservative"
                           )))

# - plot
jpeg("./plots/fig01-B.jpeg", width = 1200, height = 1200, res=225)
ggplot(susp_byideo02,
       aes(x = ideo_cat, y = susp_prop * 100, fill = ideo_cat)) +
  geom_bar(alpha = 0.6, stat = "identity") +
  geom_text(aes(x = ideo_cat, 
                y = (susp_prop * 100) + 0.6, 
                label = paste0(susp_prop * 100, "%")),
            size = 5.5) +
  geom_text(aes(x = ideo_cat, 
                y = (susp_prop * 100) + 0.45, 
                label = paste0("\n(", susp_n, " / ", 
                               format(n, big.mark = ","), ")")), 
            size = 4.5) +
  scale_fill_manual("", values = c("orange2", "blue4", "gray80", "red4")) +
  scale_y_continuous("% suspended", limits = c(0, 5.5), 
                     breaks = seq(0, 6, 1),
                     labels = seq(0, 6, 1),
                     expand = c(0.01,0)) +
  scale_x_discrete("") +
  #theme_ipsum_rc() + # THIS IS THE THEME USED IN THE ACTUAL FIGURE IN THE PAPER
  theme(
        #--- THIS COSEMTIC SETTINGS ARE ONLY FOR THE REPLICATION MATERIAL ---#
        #--- TO AVOID ISSUES WITH FONT DEPENDENCIES -------------------------#
        panel.background = element_blank(),
        #--------------------------------------------------------------------#
        legend.position = "none",
        axis.text.x = element_text(size = 14),
        panel.grid.major.x = element_blank(),
        strip.placement = "outside",
        strip.text = element_text(hjust = 0.5, size = 20),
        axis.title.y = element_text(size = 14))
dev.off()
