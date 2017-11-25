#' Monte Carlo Simulations for an Inverse CDF
#' 
#' \code{clt()} runs Monte Carlo simulations for a given inverse cdf. 
#' Outputs the z-score of individual simulations for each sample size 
#' to a data frame.
#'
#' @param N The sample sizes (number of draws) you would like to test,
#' must be a vector of integers greater than 1. 
#' @param invcdf A string representing the unevaluated inverse cdf. This MUST include
#' the variable n (the sample size), typically enclosed by \code{runif()}, like so \code{runif(n).}
#' @param B The number of simulations to run for each sample.
#' @param mu The actual known mean of the pdf.
#'
#' @examples
#'
#' # The below will sample a uniform distribution 10000 times, drawing 2, 10,
#' # 40, and 500 for each simulation and output a data frame.
#' 
#' df <- clt(N = c(2,10,40,500), invcdf = "runif(n, -1, 1)", B = 10000)
#' 
#' @export

clt <- function(N = NULL, invcdf = NULL, B = 1000, mu = 0) {
  if (!is.character(invcdf)) {
    stop("invcdf must be a string expression for the formula of an inverse cdf")
  } 
  if (min(N) <= 1 || !is.numeric(N) || !is.atomic(N)) {
    stop("N must be an atomic vector containing only integers greater than 1")
  }
  clt.df <- data.frame(matrix(NA, B, length(N)))
  
  for (n in N) {
    for (i in 1:B) {
      clt.sample <- eval(parse(text = invcdf))
      clt.df[i, match(n,N)] <- (mean(clt.sample) - mu) / (sd(clt.sample) / sqrt(n))
    }
  }
  colnames(clt.df) <- N
  
  return(clt.df)
}