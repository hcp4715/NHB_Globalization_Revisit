BayesMultiNomial <- function(dataset, factor, observed, expected, default_prior = TRUE, prior = NA){
  # datase - the input dataframe
  # factor - column name of the factor,
  # observed - column name of the column contains counts information for the observed,
  # expected - column name of the column contains counts information for the expected,
  # default_prior - whether use the default, defused prior
  # prior - priors defined by users
  
  library(tidyverse)
  
  fact_level <- dataset %>% dplyr::select(all_of(factor)) %>% dplyr::pull() #  %>% as.factor(.)
  observed_data <- dataset %>% dplyr::select(all_of(observed)) %>% dplyr::pull()
  names(observed_data) <- fact_level
  expected_data <- dataset %>% dplyr::select(all_of(expected)) %>% dplyr::pull()
  n_levels <- length(observed_data)
  
  if (default_prior & is.na(prior)) {
    prior <- rep(1, n_levels)
  } else{
    prior <- prior
  }
  
  alphas <- prior
  counts <- observed_data
  thetas <- expected_data
  
  if(sum(thetas) != 1) {
    thetas <- thetas/sum(thetas)
  }
  
  expected <- setNames(sum(counts)*thetas, names(counts))
  
  lbeta.xa <- sum(lgamma(alphas + counts)) - lgamma(sum(alphas + counts))
  lbeta.a  <- sum(lgamma(alphas)) - lgamma(sum(alphas))
  
  if (any(rowSums(cbind(thetas, counts)) == 0)) {
    LogBF10 <- (lbeta.xa-lbeta.a)
  } else {
    LogBF10 <- (lbeta.xa-lbeta.a) + (0 - sum(counts * log(thetas))) 
  }
  
  BF <- data.frame(LogBF10 = LogBF10,
                   BF10    = exp(LogBF10),
                   BF01    = 1/exp(LogBF10))
  
  return(list(BF       = BF,
              expected = expected))
  
}