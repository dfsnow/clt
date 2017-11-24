#' Evaluating Z-Scores Created by \code{clt()}
#' 
#' \code{clt_eval()} evaluates the results from \code{clt()}. It outputs the 
#' percentage of z-scores which fell outside the specified critical values.
#'
#' @param data The data frame of z-scores to be evaluated.
#' @param ci The confidence interval you would like to evaluate at. 
#' @param zonly If true, outputs only z-scores as a vector. If false,
#' outputs z-scores paired with N size as a data frame. 
#' 
#' @examples
#' 
#' # The below will sample a uniform distribution 10000 times, drawing 2, 10,
#' # 40, and 500 for each simulation and output a data frame. It will the output
#' # the percentage of each N's simulated z-scores which were above the critical
#' # value specified. 
#' 
#' df <- clt(N = c(2,10,40,500), invcdf = "runif(n, -1, 1)", B = 10000)
#' clt_eval(df, ci = 1.96)
#' 
#' # You can also use the pipe operator to pass the results of \code{clt()} to \code{clt_eval()}.
#' 
#' clt(N = c(2,10,40,500), invcdf = "runif(n, -1, 1)", B = 10000) %>% clt_eval()
#' 
#' @export

clt_eval <- function(data = NULL, ci = 1.96, zonly = TRUE) {
  if (zonly == TRUE && is.data.frame(data) == TRUE) {
    clt_eval.vec <- c()
    for (i in 1:ncol(data)){
      clt_eval.vec[i] <- sum(
        ifelse((abs(data[,i]) > ci), 1, 0)/sum(
          ifelse(data[,i], 1, 0)
        )
      )
    }
    return(clt_eval.vec)
  } else if (zonly == TRUE && is.atomic(data) == TRUE) {
    clt_eval.vec <- c()
    return(clt_eval.vec <- sum(
      ifelse((abs(data) > ci), 1, 0)/sum(
        ifelse(data, 1, 0)
        )
      )
    )
  }

  clt_eval.df <- data.frame(matrix(NA, 1, 2))
  colnames(clt_eval.df) <- c("N", "% of Z-Scores Rejected")
  
  for (i in colnames(data)){
    clt_eval.df[match(i,names(data)),1] <- i
    clt_eval.df[match(i,names(data)),2] <- sum(
      ifelse((abs(data[[i]]) > ci), 1, 0)/sum(
        ifelse(data[[i]], 1, 0)
      )
    )
  }
  return(clt_eval.df)
}
