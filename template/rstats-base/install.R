## Usage: move it inside /usr/local/bin
## default uses the DESCRIPTION file from the current directory

## Install versioned packages: uses VersionedPackages field in DESCRIPTION
## VersionedPackages: devtools (1.11.0), mypackage (>= 1.12.0, < 1.14)
## R -q -e 'source("/usr/local/bin/install.R"); install$versioned()'

## List libraries listed in the SystemRequirements field of DESCRIPTION
## concatenated and saved into requirements.txt
## R -q -e 'source("/usr/local/bin/install.R"); install$sysreqs()'
## LIBS=$(cat requirements.txt); rm requirements.txt

install <- local({

  ## list SystemRequirements separated by space
  sysreqs <- function(pkgdir = ".", file="requirements.txt") {
    descr <- as.list(as.data.frame(read.dcf(paste0(pkgdir, "/DESCRIPTION"))))
    if (!is.null(descr$SystemRequirements)) {
      out <- trimws(strsplit(descr$SystemRequirements, ",")[[1]])
      out <- paste(out, collapse=" ")
    } else {
      out <- ""
    }
    writeLines(out, paste0(pkgdir, "/", file))
  }

  ## install versioned packages listed in VersionedPackages
  ## ... passes args to remotes::install_version
  versioned <- function(pkgdir = ".", ...) {
    descr <- as.list(as.data.frame(read.dcf(paste0(pkgdir, "/DESCRIPTION"))))
    if (!is.null(descr$VersionedPackages)) {
      h <- function(x) {
        x <- gsub("<", "< ", x)
        x <- gsub(">", "> ", x)
        x <- gsub("< =", "<= ", x)
        x <- gsub("> =", ">= ", x)
        x <- gsub("<=", "<= ", x)
        x <- gsub(">=", ">= ", x)
        x <- gsub("  ", " ", x)
        x
      }
      pkgs <- gsub("[[:space:]]", "", descr$VersionedPackages)
      pkgs <- strsplit(pkgs, "),", fixed=TRUE)[[1]]
      pkgs <- gsub(")", "", pkgs, fixed=TRUE)
      pkgs <- strsplit(pkgs, "(", fixed=TRUE)
      for (i in seq_along(pkgs)) {
        pkgs[[i]][2L] <- gsub(",", ", ", pkgs[[i]][2L])
        pkgs[[i]][2L] <- h(pkgs[[i]][2L])
      }
      lapply(pkgs, function(z) remotes::install_version(z[1L], z[2L], ...))
    }
    invisible(NULL)
  }

  list(
    versioned = versioned,
    sysreqs = sysreqs
  )

})
