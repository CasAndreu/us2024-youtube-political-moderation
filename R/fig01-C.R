#===============================================================================
# fig01-C.R
# Title:    Little evidence of ideological bias in YouTube suspensions of 
#             political content during the 2024 US Election
# Purpose:  Code to replicate Figure 1.C in the paper, showing cumulative 
#             channel suspension for the full time period, by ideology.
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
# - select only suspended channels
susp_channels <- channel_db %>%
  filter(channel_susp == 1)

# - create a date-only variable from the suspension tstamp
susp_channels$channel_susp_dateonly <- sapply(
  susp_channels$channel_susp_tstamp, function(x)
  strsplit(x, split = " ")[[1]][1])

susp_channels <- susp_channels %>% 
  mutate(channel_susp_dateonly = as.Date(channel_susp_dateonly),
         channel_susp_yearweek = format(channel_susp_dateonly, "%Y-%U"))

# - calculate cumulative suspensions by year-week, and by ideology
susp_ch_cum <- susp_channels %>%
  arrange(channel_susp_yearweek) %>%
  group_by(ideo_cat, channel_susp_yearweek) %>%
  summarise(n = n()) %>%
  as.data.frame() %>%
  group_by(ideo_cat) %>%
  summarise(cum_n = cumsum(n),
            channel_susp_yearweek = channel_susp_yearweek, 
            susp_n = n) %>%
  mutate(ideo_cat = factor(ideo_cat, levels = c("Liberal", "Moderate", "Conservative")))

# - plot
jpeg("./plots/fig01-C.jpeg", width = 1400, height = 1200, res=225)
ggplot(susp_ch_cum,
       aes(x = as.Date(paste0(channel_susp_yearweek, "-0"), format = "%Y-%U-%w"), y = cum_n)) +
  geom_line(aes(group = ideo_cat, color = ideo_cat), size = 1.5) +
  scale_x_date("", 
               date_breaks = "1 month",
               date_labels = "%b %Y"  # %b = abbreviated month name (Jan, Feb, etc.)
  ) +
  #theme_ipsum_rc() +
  scale_y_continuous("Cumulateive number of suspended channels") +
  scale_color_manual("", values = c( "blue4",  "gray60", "red4")) +
  theme(#--- THIS COSEMTIC SETTINGS ARE ONLY FOR THE REPLICATION MATERIAL ---#
        #--- TO AVOID ISSUES WITH FONT DEPENDENCIES -------------------------#
        panel.background = element_blank(),
        #--------------------------------------------------------------------#
        axis.text.x = element_text(angle = 45, vjust = 1, hjust=1, size = 10),
        legend.position = "top",
        legend.text = element_text(size = 14),
        axis.title.y = element_text(size = 12)) 
dev.off()
