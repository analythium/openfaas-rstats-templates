## Usage: move it inside /usr/local/bin
## default uses the DESCRIPTION file from the current directory

## Install dependencies:
## R -q -e 'source("/usr/local/bin/install.R"); install$dependencies()'

## Install from local folder:
##   local is path to local directory,
##   or compressed file (tar, zip, tar.gz tar.bz2, tgz2 or tbz)
## R -q -e 'source("/usr/local/bin/install.R"); install$local()'

## Install versioned packages: uses VersionedPackages field in DESCRIPTION
## VersionedPackages: devtools (1.11.0), mypackage (>= 1.12.0, < 1.14)
## R -q -e 'source("/usr/local/bin/install.R"); install$versioned()'

## List libraries listed in the SystemRequirements field of DESCRIPTION
## by default concatenated and saved into tmpfile
## R -q -e 'source("/usr/local/bin/install.R"); install$sysreqs()'
## LIBS=$(cat tmpfile); rm tmpfile

install <- local({

  ## list SystemRequirements as a vector or separated by space
  sysreqs <- function(pkgdir = ".", file="tmpfile") {
    descr <- as.list(as.data.frame(read.dcf(paste0(pkgdir, "/DESCRIPTION"))))
    if (!is.null(descr$SystemRequirements)) {
      out <- trimws(strsplit(descr$SystemRequirements, ",")[[1]])
      out <- paste(out, collapse=" ")
    } else {
      out <- ""
    }
    writeLines(out, paste0(pkgdir, "/", file))
  }

  ## install versioned packages listed in the VersionedPackages
  ## 
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

  ## local is path to local directory,
  ## or compressed file (tar, zip, tar.gz tar.bz2, tgz2 or tbz)
  list(
    dependencies = remotes::install_deps,
    local = remotes::install_local,
    versioned = versioned,
    sysreqs = sysreqs
  )

})
