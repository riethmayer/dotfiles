if (interactive()) {
  suppressMessages(require(devtools))
}

# devtools options
options("devtools.desc" = list(
          Author = "Jan Riethmayer",
          Maintainer = "Jan Riethmayer <jan@riethmayer.com>",
          License = "MIT + file LICENSE",
          Version = "1.0.0"
        ))
options("devtools.name" = "Jan Riethmayer")

.env <- new.env()

.env$q <- function (save = "no", ...) base::quit(save = save, ...)
.env$`%nin%` <- function(x, y) !(x %in% y)
.env$cd <- base::setwd
.env$pwd <- base::getwd

attach(.env)

.First <- function() {
  options(
    repos = c(CRAN = "https://cran.rstudio.com/"),
    browserNLdisabled = TRUE,
    deparse.max.lines = 2,
    digits.secs = 3,
    tab.width = 2,
    max.print = 100,
    scipen = 10,
    prompt = "R> ",
    continue = "... ")
}
