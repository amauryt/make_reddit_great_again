# -----------------------------------------
# Common variables throughout the analysis
# -----------------------------------------


# INTERVENTION PERIODS

day_delta <- 210L # 30 weeks
grace_days <- 7L

quarantine_color  <- "darkorange"   
quarantine_date   <- as.Date('2019-06-26')
pre_q_start_date  <- quarantine_date - day_delta
pre_q_end_date    <- quarantine_date - 1
post_q_start_date <- quarantine_date + 1
post_q_end_date   <- quarantine_date + day_delta

restriction_color <- "red3"   
restriction_date  <- as.Date('2020-02-26')
pre_r_start_date  <- restriction_date - day_delta
pre_r_end_date    <- restriction_date - 1
post_r_start_date <- restriction_date + 1
post_r_end_date   <- restriction_date + day_delta

narrowed_restriction_offset <- 84L # 12 weeks

ban_date <- as.Date('2020-06-29')
ban_color <- "gray20"

george_floyd_unrest_start_date <- as.Date('2020-05-26')
george_floyd_unrest_start_offset <- as.numeric(george_floyd_unrest_start_date - restriction_date)

intervention_periods_for_bsts <- list(
  quarantine = list(
    pre = c(pre_q_start_date, pre_q_end_date),
    post = c(quarantine_date, post_q_end_date)
  ),
  restriction = list(
    pre = c(pre_r_start_date, pre_r_end_date),
    post = c(restriction_date, post_r_end_date)
  ),
  narrowed_restriction = list(
    pre = c(restriction_date - narrowed_restriction_offset, pre_r_end_date),
    post = c(restriction_date, restriction_date + narrowed_restriction_offset)
  )
)

# CONTENT COLORS

submission_color <- "#bebada"
submission_users_color <- "#fccde5"
comment_color <- "#8dd3c7"
comment_users_color <- "#80b1d3"
sevtox_color <- "#fb8072"

content_colors <- c(submission_color, comment_color)
names(content_colors) <- c("submissions", "comments")


# SUBREDDIT AND BOT IDs

automoderator_id <- 11063919
botforceone_id <- 23458172602
the_donald_id <- 5451831
conservative_id <- 4594561


# QUALITY OF SHARED INFORMATION

bias_levels <- c(
  "left",
  "left-center",
  "least biased",
  "right-center",
  "right",
  "fake",
  "conspiracy/pseudoscience",
  "satire",
  "pro-science"
)
political_bias_levels <- bias_levels[1:5]
general_bias_levels <- c("political", bias_levels[6:9])

accuracy_levels <- c(
  "very low",
  "low",
  "mixed",
  "mostly factual",
  "high",
  "very high"
)
