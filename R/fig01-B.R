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
data_path <- "~/Desktop/repos/DATA-sm-political-moderation/"

# DATA
#===============================================================================