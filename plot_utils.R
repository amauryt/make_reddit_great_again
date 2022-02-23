library(ggplot2)
library(colorspace)

theme_set(theme_bw())

activity_its_plot <- function(
    dt,
    col_suffix,
    s_color,
    c_color,
    its_lm,
    intervention,
    y_lab,
    scale_labels
) {
  assert_data_table(dt)
  assert_list(its_lm)
  assert_choice(intervention, c("quarantine", "restriction"))
  
  intervention_color <- get(paste0(intervention, "_color"))
  s_col <- paste0("s_", col_suffix)
  c_col <- paste0("c_", col_suffix)
  i_s_dt <- fortify(its_lm[[s_col]])
  i_c_dt <- fortify(its_lm[[c_col]])
  i_s_dt$created_day <- dt$created_day
  i_c_dt$created_day <- dt$created_day
  dt |> 
    ggplot(aes(created_day)) +
    geom_line(aes_(y = as.formula(paste0("~", s_col)), color = lighten(s_color, 0.575))) +
    geom_line(aes_(y = as.formula(paste0("~", c_col)), color = lighten(c_color, 0.575))) +
    geom_vline(xintercept = 0, color = intervention_color, lwd = 0.5) +
    scale_y_log10() +
    geom_line(data = i_s_dt, aes(x = created_day, y = .fitted), color = s_color, lwd = 1.25) +
    geom_line(data = i_c_dt, aes(x = created_day, y = .fitted), color = c_color, lwd = 1.25) +
    scale_color_identity(
      name = NULL,
      guide = "legend",
      labels = scale_labels
    ) +
    labs(
      y = y_lab,
      x = paste("Days relative to", intervention)
    ) +
    theme(
      legend.position = "top",
    )
}

sev_tox_its_plot <- function(
    dt,
    col_name,
    sevtox_its_lm,
    intervention,
    y_lab
) {
  check_choice(intervention, c("quarantine", "restriction"))
  intervention_color <- get(paste0(intervention, "_color"))
  sevtox_dt <- fortify(sevtox_its_lm[[col_name]])
  sevtox_dt$created_day <- dt$created_day
  dt |> 
    ggplot(aes(created_day)) +
    geom_line(aes_(y = as.formula(paste0("~", col_name))), color = lighten(sevtox_color, 0.6)) +
    geom_vline(xintercept = 0, color = intervention_color, lwd = 0.5) +
    geom_line(data = sevtox_dt, aes(x = created_day, y = .fitted), color = sevtox_color, lwd = 1.25) +
    labs(
      y = y_lab,
      x = paste("Days relative to", intervention)
    ) +
    theme(
      legend.title = element_blank()
    )
}


add_george_floyd_layers_to_sev_tox_plot <- function(tox_plot, n_sevtox_its_lm, col_name) {
  assert_class(tox_plot, "ggplot")
  n_sevtox_dt <- fortify(n_sevtox_its_lm[[col_name]])
  n_sevtox_dt$created_day <- -84:84
  tox_plot +
    geom_vline(
      xintercept = george_floyd_unrest_start_offset,
      lty = "longdash",
      color = "gray30"
    ) +
    geom_line(data = n_sevtox_dt, aes(x = created_day, y = .fitted, color = "darkblue"), lwd = 1.25, alpha = 0.65) +
    scale_color_identity(
      name = NULL,
      guide = "legend",
      labels = c("Narrowed ITS (±12 weeks )")
    ) +
    theme(
      legend.title = element_text(),
      legend.position = c(0.23, 0.8),
      legend.margin = margin(0, 5, 5, 5),
      legend.background = element_rect(fill = "white", linetype = "dashed", size=0.25, color = "gray")
    )
}
