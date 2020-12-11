#!/usr/bin/env Rscript
FILE <- commandArgs(trailingOnly = TRUE)[1L]
#' Install R package dependencies found in PACKAGES
#'
#' set remote to RStudio server
repos <- "https://cran.rstudio.com/"
#' prevent asking upgrade: use "never" or "always"
#' or set R_REMOTES_UPGRADE when "default"
upgrade <- "never"
#' load remotes package
library(remotes)
#' function to read in PACKAGES
#' each dependency is on a new line (no separators)
#' remotes in PACKAGES defined according to:
#' https://cran.r-project.org/web/packages/remotes/vignettes/dependencies.html
read_requirements <- function(file) {
  x <- readLines(file)
  x <- gsub("[[:space:]]", "", x)
  x[nchar(x) > 0]
}
#' function to parse character vector & install
install <- function(x, ...) {
  ## parse installation sources: (source, pkg)
  x <- strsplit(x, "::")
  for (i in which(sapply(x, length) < 2L)) {
    if (grepl("/", x[[i]])) {
      x[[i]] <- c("github", x[[i]])
    } else {
      if (grepl("@", x[[i]])) {
        tmp <- strsplit(x[[i]], "@")[[1L]]
        x[[i]] <- c("version", tmp[1L])
        attr(x[[i]], "version") <- tmp[2L]
      } else {
        x[[i]] <- c("cran", x[[i]])
      }
    }
  }
  ## install packages
  f <- function(z, ...) {
    switch(z[1L],
      "cran" = install_cran(z[2L], ...),
      "version" = install_version(z[2L], attr(z, "version"), ...),
      "github" = install_github(z[2L], ...),
      "dev" = install_dev(z[2L], ...),
      "bioc" = install_bioc(z[2L], ...),
      "bitbucket" = install_bitbucket(z[2L], ...),
      "gitlab" = install_gitlab(z[2L], ...),
      "git" = install_git(z[2L], ...),
      "local" = install_local(z[2L], ...),
      "svn" = install_svn(z[2L], ...),
      "url" = install_url(z[2L], ...),
      stop(sprintf("unsupported installation sources: %s", z[1L])))
  }
  lapply(x, f, ...)
  invisible(NULL)
}
#' now the actuall installation
install(
  read_requirements(FILE),
  repos = repos,
  upgrade = upgrade)
#' the end
