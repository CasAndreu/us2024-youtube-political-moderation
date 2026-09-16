#===============================================================================
# fig01-E.R
# Title:    Little evidence of ideological bias in YouTube suspensions of 
#             political content during the 2024 US Election
# Purpose:  Code to replicate Figure 1.D in the paper, showing proportion of
#             suspended channels by topical focus of the channel. These channel
#             labels are self-reported/chosen by channel owners, and they choose
#             1+ labels.
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
susp_bytlabel <- channel_db %>%
  dplyr::select(channel_id, channel_susp,
                society, sociology, knowledge, politics, religion,
                entertainment, film, televisionprogram, technology, military,
                vehicle, hobby, food, tourism, humour, pet, fashion, business,
                performingarts, anygame, anymusic, anysports, anyphysichealth) %>%
  gather(tlabel, value, -channel_id, -channel_susp) %>%
  filter(value == 1) %>%
  dplyr::select(-value) %>%
  group_by(tlabel) %>%
  summarise(n = n(),
            susp_n = sum(channel_susp)) %>%
  mutate(prop = round(susp_n / n, 4)) %>%
  mutate(tlabel = tools::toTitleCase(tlabel)) %>%
  mutate(tlabel = recode(tlabel,
                         `Anygame` = "Gaming",
                         `Anymusic` = "Music",
                         `Anyphysichealth` = "Health & Body",
                         `Anysports` = "Sports",
                         `Performingarts` = "Arts",
                         `Televisionprogram` = "Television")) %>%
  as.data.frame() %>%
  arrange(desc(prop)) %>%
  mutate(tlabel = factor(tlabel, levels = rev(unique(tlabel))))


jpeg("./plots/fig01-E.jpeg", width = 2000, height = 1500, res=225)
ggplot(susp_bytlabel,
       aes(x = tlabel, y = prop * 100)) +
  geom_bar(stat = "identity", fill = "gray70", width = 0.8) +
  geom_text(aes(label = paste0(susp_n, " / ", n, " (", prop * 100, "%)"),
                y = (prop * 100) + 0.5),
            hjust = 0, size = 4.5) +
  coord_flip() +
  scale_x_discrete("") +
  scale_y_continuous("", breaks = NULL, limits = c(0, 25),
                     expand = c(0.01,0)) +
  #theme_ipsum_rc() +
  theme(panel.background = element_blank(),
        panel.grid.major.y = element_blank(),
        axis.ticks = element_blank(),
        legend.position = "none",
        axis.text.y = element_text(size = 14),
        plot.title = element_text(
          hjust = 1,
          size = 20,
          face = "bold"
        ))
dev.off()  


