#' The Lobato and Velasco's Test for normal distribution
#'
#' Performs the Lobato and Velasco's test for normal distribution of
#' a univariate stationary process.The initial hypothesis (H0), is
#' that Y process follows a normal distribution.
#'
#' @usage  lobato.test(y,c = 1)
#'
#' @param y a numeric vector or an object of the ts class containing an univariate
#' stationary time series.
#' @param c a positive real value that identifies the total amount of values that
#' are going to be used in the cumulative sum
#'
#' @return A h.test class with the main results of the Lobato and Velasco's hypothesis test. The
#' h.test class have the following values
#' \itemize{
#'  \item{"lobato"}{The Lobato and Velasco's statistic}
#'  \item{"df"}{The test degrees freedoms}
#'  \item{"p.value"}{The p value}
#'  \item{"alternative"}{The alternative hypothesis}
#'  \item{"method"}{The used method}
#'  \item{"data.name"}{The data name}
#' }
#'
#' @details
#'
#' This test  proof a normality assumptions in correlated data, employing the
#' skewness-kurtosis test statistic, but studentized by standard error estimators
#' that are consistent under serial dependence of the observations. The test was
#' proposed by \emph{Lobato, I., & Velasco, C. (2004)} and implemented by
#' \emph{Nieto-Reyes, A., Cuesta-Albertos, J. & Gamboa, F. (2014)}
#'
#' @export
#'
#' @author Asael Alonzo Matamoros
#'
#' @seealso \code{\link{lobato.statistic}},\code{\link{epps.test}}
#'
#' @references
#' Lobato, I., & Velasco, C. (2004). A simple test of normality in time series.
#' \emph{Journal of econometric theory}. 20(4), 671-689.
#' \url{doi:10.1017/S0266466604204030}
#'
#' Nieto-Reyes, A., Cuesta-Albertos, J. & Gamboa, F. (2014). A random-projection
#' based test of Gaussianity for stationary processes. \emph{Computational
#' Statistics & Data Analysis, Elsevier}, vol. 75(C), pages 124-141.
#' \url{http://www.sciencedirect.com/science/article/pii/S0167947314000243}
#' \code{doi:https://doi.org/10.1016/j.csda.2014.01.013}.
#'
#' @examples
#' # Generating an stationary arma process
#' y = arima.sim(100,model = list(ar = 0.3))
#' lobato.test(y)
#'
lobato.test = function(y, c = 1){

  if( !is.numeric(y) & !is(y,class2 = "ts") )
    stop("y object must be numeric or a time series")

  if(NA %in% y )
    stop("The time series contains missing values")

  # checking stationarity
  cc = uroot.test(y)
  if(!cc$stationary)
    warning("y has a unit root, lobato.test requires stationary process")

  # checking seasonality
  if(frequency(y) > 1){
    cc = seasonal.test(y)
    if(cc$seasonal)
      warning("y has a seasonal unit root, lobato.test requires stationary process")
  }

  dname = deparse(substitute(y))
  alt = paste(dname,"is not Gaussian")
  tstat = lobato.statistic(y, c = c)
  names(tstat) <- "lobato"
  df =  2
  names(df) <- "df"
  pval = pchisq(q = tstat,df =df,lower.tail = FALSE)

  rval <- list(statistic =tstat, parameter = df, p.value = pval,
               alternative = alt,
               method = "Lobatos and Velascos test", data.name = dname)
  class(rval) <- "htest"
  return(rval)
}
#'  Computes the Lobato and Velasco statistic
#'
#' Computes the Lobato and Velasco statistic for a univariate stationary process.
#' This test  proof a normality assumptions in correlated data, employing the
#' skewness-kurtosis test statistic, but studentized by standard error estimators
#' that are consistent under serial dependence of the observations
#'
#' @usage lobato.statistic(y,c = 1)
#'
#' @param y a numeric vector or an object of the ts class containing an univariate
#' time series to be tested
#' @param c a positive real value that identifies the total amount of values that
#' are going to be used in the cumulative sum
#'
#' @details This function is the equivalent of \code{GestadisticoVn} of \emph{Nieto-Reyes, A.,
#' Cuesta-Albertos, J. & Gamboa, F. (2014)}.
#'
#' @return A real value with the Lobato and Velasco test's statistic
#'
#' @export
#'
#' @author  Asael Alonzo Matamoros.
#'
#' @keywords Lobato and Velasco's test, G.statistic
#'
#' @seealso \code{\link{epps.statistic}}
#'
#' @references
#' Lobato, I., & Velasco, C. (2004). A simple test of normality in time series.
#' \emph{Journal of econometric theory}. 20(4), 671-689.
#' \url{doi:10.1017/S0266466604204030}
#'
#' Nieto-Reyes, A., Cuesta-Albertos, J. & Gamboa, F. (2014). A random-projection
#' based test of Gaussianity for stationary processes. \emph{Computational
#' Statistics & Data Analysis, Elsevier}, vol. 75(C), pages 124-141.
#' \url{http://www.sciencedirect.com/science/article/pii/S0167947314000243}
#' \code{doi:https://doi.org/10.1016/j.csda.2014.01.013}.
#'
#' @examples
#' # Generating an stationary arma process
#' y = arima.sim(100,model = list(ar = 0.3))
#' lobato.statistic(y,3)
#'
lobato.statistic = function(y,c = 1){

  if( !is.numeric(y) & !is(y,class2 = "ts") )
    stop("y object must be numeric or a time series")

  if(NA %in% y )
    stop("The time series contains missing values")

  # Identifiying the process sample statistics
  n = length(y)
  mu1 = mean(y)
  mu2 = var(y)*(n-1)/n
  mu3 = sum((y-mu1)^3)/n
  mu4 = sum((y-mu1)^4)/n

  hn  = ceiling(c*sqrt(n)-1)
  gamma = rep(0,hn)

  for (j in 1:hn) {
    if( n-j > 0 ){
      yt = y[1:(n-j)]
      gamma[j] = sum((yt-mu1)*(y[(1+j):n]-mu1))/n
      if(is.na(gamma[j])) gamma[j] = 0
    }
    else gamma[j] = 0
  }
  hnm = hn+1; gat =  rep(0,hn)
  for (j in 1:hn) gat[j] = gamma[hnm-j]

  F3 = abs(2*sum(gamma*(gamma+gat)^2)+mu2^3)
  F4 = abs(2*sum(gamma*(gamma+gat)^3)+mu2^4)
  G = n*(mu3^2/(6*F3)+(mu4-3*mu2^2)^2/(24*F4))

  return(G)
}