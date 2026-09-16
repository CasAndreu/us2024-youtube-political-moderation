#===============================================================================
# fig01-D.R
# Title:    Little evidence of ideological bias in YouTube suspensions of 
#             political content during the 2024 US Election
# Purpose:  Code to replicate Figure 1.D in the paper, showing the proportion
#             of monthly channel suspension accounted for each ideology.
# Author:   Andreu Casas
#===============================================================================

# PACKAGES
#===============================================================================
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)

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

# - express suspension date as year-month
susp_channels$channel_susp_dateonly <- sapply(
  susp_channels$channel_susp_tstamp, function(x)
  strsplit(x, split = " ")[[1]][1])

susp_channels <- susp_channels %>% 
  mutate(channel_susp_month = format(as.Date(channel_susp_dateonly), "%Y-%m"))

# - calculate the prop. each ideology accounts of the monthly proportions
susp_ch_month <- susp_channels %>%
  group_by(ideo_cat, channel_susp_month) %>%
  summarise(susp_n = n()) %>%
  as.data.frame() %>%
  group_by(channel_susp_month) %>%
  summarise(denom = sum(susp_n),
            con = susp_n[ideo_cat == "Conservative"],
            lib = susp_n[ideo_cat == "Liberal"],
            mod = susp_n[ideo_cat == "Moderate"]) %>%
  mutate(con_prop = con / denom,
         lib_prop = lib / denom,
         mod_prop = mod / denom) %>%
  dplyr::select(channel_susp_month, con_prop, lib_prop, mod_prop) %>%
  gather(ideo, prop, -channel_susp_month) %>%
  rename(Month = channel_susp_month,
         Ideology = ideo) %>%
  mutate(Ideology = recode(Ideology,
                           `con_prop` = "Conservative",
                           `mod_prop` = "Moderate",
                           `lib_prop` = "Liberal"),
  Ideology = factor(Ideology, levels = c(
    "Conservative", "Moderate", "Liberal"
  ))) %>%
    as.data.frame() %>%
    mutate(Month = ym(Month),
           month_value = format(Month, "%Y-%m"))

# - plot
jpeg("./plots/fig01-D.jpeg", width = 1400, height = 1200, res=225)
ggplot(susp_ch_month,
       aes(x = month_value, y = prop, fill = Ideology)) +
  geom_bar(stat = "identity", color = "black", width = 1, alpha = 0.6) +
  geom_text(inherit.aes = FALSE,
            data = susp_ch_month %>% filter(Ideology == "Conservative"),
            aes(x = month_value, y = 0.96, 
                label = paste0(round(prop * 100), "%")),
            size = 3.5) +
  geom_text(inherit.aes = FALSE,
            data = susp_ch_month %>% filter(Ideology == "Liberal"),
            aes(x = month_value, y = 0.04, 
                label = paste0(round(prop * 100), "%")),
            size = 3.5) +
  geom_hline(yintercept = 0.5) +
  scale_fill_manual("", values = c("red4",  "gray80", "blue4")) +
  scale_y_continuous("% of suspended accounts", 
                     breaks = seq(0, 1, 0.25),
                     labels = paste0(seq(0, 100, 25), "%"),
                     expand = c(0,0)) +
  scale_x_discrete("", labels = format(seq(
    from = ym("2023-08"),
    to   = ym("2024-11"),
    by   = "month"
  ), "%b %Y"), expand = c(0,0)) +
  #theme_ipsum_rc() +
  theme(panel.background = element_blank(),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust=1, size = 10),
        axis.title.y = element_text(size = 12),
        axis.text.y = element_text(size = 11),
        axis.ticks.x = element_blank(),
        legend.text = element_text(size = 12),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = "top")
dev.off()