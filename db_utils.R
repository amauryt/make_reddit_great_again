library(data.table)
library(checkmate)
library(RSQLite)

retrieve_db_table <- function(db_name, table_name) {
  assert_choice(db_name, c("the_donald", "core_the_donald"))
  assert_choice(table_name, c("submissions", "comments", "subreddits", "perspective_scores"))
  
  db_path <- paste0("./data/", db_name,".sqlite")
  query <- paste("SELECT * FROM", table_name)
  db_cnn <- dbConnect(SQLite(), db_path)
  dt <- dbGetQuery(db_cnn, query)
  setDT(dt)
  
  if (any(colnames(dt) == "created_utc")) {
    dt[, created_date := as.Date.POSIXct(created_utc)]
    dt[, created_utc := NULL]
  }
  if (any(colnames(dt) == "body_erased")) {
    dt[, body_erased := as.logical(body_erased)]
  }
  if (any(colnames(dt) == "is_self")) {
    dt[, is_self := as.logical(is_self)]
  }

  dbDisconnect(db_cnn)
  dt
}