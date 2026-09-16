# Little evidence of ideological bias in YouTube suspensions of political content during the 2024 US Election
This repository contains replication code for the paper "Little evidence of ideological bias in YouTube suspensions of political content during the 2024 US Election"

> __Abstract__:
> Social media play a crucial role in moderating speech. In the United States, conservative elites claim that platforms unfairly sanction conservative voices. Yet systematic, large-scale analysis is lacking. For more than a year leading up to the 2024 Election, we monitored 20,000 YouTube channels posting about US politics, and their millions of videos. By election day, the platform had removed 2.17% of the channels and 3.3% of the videos. Conservative channels and videos were suspended 3-4 times more frequently than liberal ones. However, conservative videos accounted for most the hateful content (58.18% v. 23.35%, for liberal videos) and misinformation and conspiracies (71.9% v. 10.08%), as identified using fine-tuned Vision Language Models. Accounting for platform violations explains most of the ideological gap in suspensions, leaving a residual difference of less than a percentage point, suggesting that ideological differences reflected asymmetries in compliance with platform policy far more than a uniform ideological moderation bias.

## Downloading Large Files from Google Drive
A few files are too large to be stored in this repository. You can find them in Google Drive. Before running any code, you should download all files from the [models](https://drive.google.com/drive/folders/1YfYObSfUdMdBIJX6CzYWPkqOQQCCo6qz?usp=sharing) folder. In the code, these files are placed in a directory right outside the repository named `../DATA-us2024-youtube-political-moderation/`. Adjust code accordingly. 

## Data
- `channels.csv`: channel-level data, key metadata (channel_id, channel name, creation date, etc.), plus estimated channel ideology. N = 20,334
- `videos-EN-nov23-nov24.csv`: video-level data. Includes EN videos posted by the tracked channels between Nov. 2023 and Nov. 2024. Metadata plus ML-generated variables (videos containing hate content, spreading misinfo, whether about politics, political topic, ideological leaning), etc.

## Code

- [fig01-B.R](https://github.com/CasAndreu/us2024-youtube-political-moderation/blob/main/R/fig01-B.R): code to generate Figure 1.B of the paper, showing channel suspension rates, by channel ideology.
