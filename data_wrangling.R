library(data.table)
library(checkmate)
library(zoo)
library(CausalImpact)


# =========================
#  Activity
# =========================

daily_activity <- function(submissions, comments) {
  assert_data_table(submissions)
  assert_data_table(comments)
  assert_subset("is_self", colnames(submissions))

  daily_s <- submissions[, .(s_count = .N), by = "created_date"]
  daily_c <- comments[, .(c_count = .N), by = "created_date"]
  daily_s_dau <- submissions[, .(s_dau = uniqueN(author_id)), by = "created_date"]
  daily_c_dau <- comments[, .(c_dau = uniqueN(author_id)), by = "created_date"]
  
  dt <- Reduce(merge, list(
    daily_s,
    daily_c,
    daily_s_dau,
    daily_c_dau
  ))
  setnafill(dt, fill = 0)
  dt
}

# =========================
#  Toxicity
# =========================

daily_sev_tox <- function(dt) {
  check_data_table(dt)
  
  dt[!is.na(severe_toxicity)
    ][,.(
        c_count = .N,
        median_sev_tox = median(severe_toxicity),
        sev_tox_count = sum(severe_toxicity >= 0.5)
      ), by = "created_date"
        ][, sev_tox_prop := sev_tox_count / c_count]
}


# =========================
#  Intervention effects on activity
# =========================

set_relative_week_and_day <- function(dt, intervention_date) {
  check_data_table(dt)
  check_date(intervention_date)
  dt[, created_day := as.integer(created_date - intervention_date)]
  dt[, created_week := fcase(
      created_day > 0, (created_day - 1) %/% 7 + 1,
      created_day < 0, created_day %/% 7,
      default = 0
    )
  ]
}

intervention_its_lm <- function(dt, y_name) {
  assert_data_table(dt)
  sub_cols <- c("created_date", y_name, "created_day") 
  check_subset(colnames(dt), sub_cols)
  
  ndt <- dt[,..sub_cols]
  ndt[,has_i := fifelse(created_day >= 0, 1, 0)]
  ndt[,days_since_i := fifelse(created_day <= 0, 0, created_day)]
  d_formula <- as.formula(paste(y_name, "~ created_date + has_i + days_since_i"))
  lm(d_formula, data = ndt)
}

intervention_bsts_effect <- function(dt, intervention, col_name) {
  assert_data_table(dt)
  assert_choice(intervention, c("quarantine", "restriction", "narrowed_restriction"))

  col_value <- as.data.frame(dt)[,col_name]

  CausalImpact(
    zoo(col_value, dt$created_date),
    intervention_periods_for_bsts[[intervention]]$pre,
    intervention_periods_for_bsts[[intervention]]$post,
    model.args = list(nseasons = 7) # Weekly seasonality
  )
}

# =========================
#  Quality of shared information
# =========================

sumission_mbfc_by_period <- function(dt, mbfc, intervention) {
  assert_data_table(dt)
  assert_data_table(mbfc)
  assert_choice(intervention, c("quarantine", "all"))

  dt <- dt[is_self == FALSE][mbfc, on = "domain", nomatch = NULL]
  if (intervention == "quarantine") {
    dt[, period := fcase(
      between(created_date, pre_q_start_date, pre_q_end_date),   "Pre-Q",
      between(created_date, post_q_start_date, post_q_end_date), "Post-Q",
      default = NA
    )]
    dt$period <- factor(dt$period, levels = c("Pre-Q", "Post-Q"))
  } else {
    dt[, period := fcase(
      between(created_date, pre_q_start_date, pre_q_end_date),   "Pre-Q",
      between(created_date, post_q_start_date, pre_r_end_date),  "Between-I",
      between(created_date, post_r_start_date, post_r_end_date), "Post-R",
      default = NA
    )]
    dt$period <- factor(dt$period, levels = c("Pre-Q", "Between-I", "Post-R"))
  }
  dt[, general_bias := fifelse(bias %in% political_bias_levels, "political", bias)]
  dt[, political_bias := fifelse(bias %in% political_bias_levels, bias, NA)]
  dt$general_bias <- factor(dt$general_bias, levels = general_bias_levels)
  dt$political_bias <- factor(dt$political_bias, levels = political_bias_levels)
  dt$accuracy <- factor(dt$accuracy, levels = accuracy_levels)

  dt[!is.na(period)
     ][,.(created_date, bias, general_bias, political_bias, accuracy, period)
       ][order(created_date)]
}


submission_mbfc_aggregation <- function(dt, col_name) {
  assert_data_table(dt)
  assert_subset("period", colnames(dt))
  
  fdt <- dt[!is.na(dt[[col_name]])]
  
  fdt_period_total <- fdt[,.(total = .N), by = "period"]
  fdt_agg <- fdt[, .N, by = c("period", col_name)]
  fdt_pct <- fdt_agg[fdt_period_total, on = "period"
          ][, percentage := N / total * 100
            ][,!c("N", "total")]
  setorderv(fdt_pct, c("period", col_name))
  fdt_pct
}
