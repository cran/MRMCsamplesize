#' Estimate sample sizes for MRMC studies
#' @import fpow
#' @description
#' \code{sampleSize_MRMC} This function returns number of cases required for a MRMC study for a given number of readers.
#'
#' @author Dennis Robert \email{dennis.robert.nm@gmail.com}
#'
#' @param endpoint Character string to inform what is the Figure-of-Merit (FOM) which will be used as the endpoint of the MRMC study. Values can be either \code{auc} or \code{sensitivity}.
#' @param J The number of readers for the study. It is recommended to have minimum 5 readers in any MRMC study.
#' @param delta Effect size denoting the anticipated difference in the endpoint between the two interventions/imaging-modalities/techniques. Typically chosen values are 0.04, 0.05 and 0.06. Should be between 0 and 1.
#' @param rangeb Inter-reader variability range (sometimes referred to as between-reader variability) denoting the anticipated difference between the highest accuracy of any reader in the study and the lowest accuracy of any reader in the study. Should be a numeric value between 0 and 1.
#' @param rangew Intra-reader variability range (sometimes referred to as within-reader variability) denoting the anticipated difference between the accuracies of a reader who interprets the same images using the same imaging technique at two different times. Should be a numeric value between 0 and 1.
#' @param theta Expected average value of the FOM for the \code{J} readers.
#' @param R Ratio of non-diseased cases to diseased cases. Defaults to 1.
#' @param r1 Correlation between FOMs of readers when same cases are evaluated by the same reader using different modalities.
#' @param r2 Correlation between FOMs when the same cases are evaluated by different readers using the same modality. It is assumed that \code{r2 = r3} for default calculations.
#' @param r3 Correlation between FOMs when the same cases are evaluated by different readers using different modalities. It is assumed that \code{r2 = r3} for default calculations.
#' @param rb Correlation between FOMs when the same readers evaluate cases using different modalities. The default value is \code{0.8}.
#' @param K Number of times each reader interprets the same case from the same modality. This is always equal to 1 in a fully-crossed paired-reader paired-case study design with two modalities.
#' @param power Power to detect \code{delta} given all other assumptions. Default value is 0.8 corresponding to 80 percent power.
#' @param alpha The type I error rate. Default value is 0.05 corresponding to 5 percent type I error (significance level).
#' @param nu1 Numerator degrees of freedom of the F-distribution which will be used to estimate the non-centrality parameter (lambda).
#' @param var_auc Variance estimation method when endpoint is \code{auc}. Defaults to the string \code{obuchowski}. If value is changed to \code{blume}, then method proposed by Blume (2009) will be used to estimate the variance.
#' @param reader_var_estimation_method  A value = \code{normal} uses the assumption that the accuracy of readers are distributed normally and thus the relationship between range and standard deviation can be used to estimate the inter and intra reader variances from \code{rangeb} and \code{rangew}. Any other value will use a rule of thumb to estimate inter and intra reader variances by dividing \code{rangeb} and \code{rangew} by 4 followed by squaring it. \code{normal} method is typically more conservative especially when J is less than 30-35.
#' @param n_reading_sessions_per_reader Number of times each reader interprets each case. Defaults to 2 which corresponds to a typical MRMC study with 2 modalities.
#' @param corr Logical value indicating if \code{ICC (intra-cluster correlation)} has to be adjusted (\code{TRUE}) or not (\code{FALSE}). Defaults to \code{FALSE}.
#' @param ICC A numerical value between 0 and 1 indicating the expected ICC if \code{corr} is \code{TRUE}.
#' @param s Average number of lesions in diseased cases. This must be a numeric value greater than or equal to 1.
#' @return
#' A list within a list object with two named lists
#' \itemize{
#'   \item \code{varComponents} - A list containing the estimated values of the OR variances and correlation components.
#'   \item \code{ORSampleSizeResults} - A list containing the sample size results.
#'}
#' @references
#' \itemize{
#' \item Obuchowski NA, Hillis SL. Sample size tables for computer-aided detection studies. AJR Am J Roentgenol. 2011 Nov;197(5):W821-8. doi: 10.2214/AJR.11.6764. PMID: 22021528; PMCID: PMC3494304
#' \item Obuchowski NA. & Rockette HE. (1995) Hypothesis testing of diagnostic accuracy for multiple readers and multiple tests an anova approach with dependent observations, Communications in Statistics - Simulation and Computation, 24:2, 285-308, DOI: 10.1080/03610919508813243
#' \item Obuchowski NA. Sample size tables for receiver operating characteristic studies. AJR Am J Roentgenol. 2000;175(3):603-608. doi:10.2214/ajr.175.3.1750603
#' \item Rockette HE, Campbell WL, Britton CA, Holbert JM, King JL, Gur D. Empiric assessment of parameters that affect the design of multireader receiver operating characteristic studies. Acad Radiol. 1999;6(12):723-729. doi:10.1016/s1076-6332(99)80468-1
#' \item Blume JD. Bounding Sample Size Projections for the Area Under a ROC Curve. J Stat Plan Inference. 2009 Mar 1;139(1):711-721. doi: 10.1016/j.jspi.2007.09.015. PMID: 20160839; PMCID: PMC2631183.
#' }
#' @details
#' When \code{corr = FALSE}, the \code{nUnits_i} in \code{ORSampleSizeResults} list is the number of diseased cases. The number of total cases (diseased + non-diseased; \code{nTotal}) required will depend on the
#' the ratio \code{R} specified.
#' When \code{corr = TRUE}, the anticipated correlation between units within the same diseased cases are adjusted and the \code{nUnits_i} in \code{ORSampleSizeResults}
#' list is the number of units in diseased cases assuming independence. The number of diseased cases required in this scenario will be given
#' by \code{nCases_c}. Again, \code{nTotal} required will depend on the \code{R} specified.
#' @examples
#' library("MRMCsamplesize")
#' result1 <- sampleSize_MRMC(endpoint = 'auc',J = 10,delta = 0.10,theta = 0.75,
#' rangeb = 0.1, rangew = 0.05, R = 1, r1 = 0.47,corr = FALSE)
#' result2 <- sampleSize_MRMC(endpoint = 'auc',J = 20,delta = 0.05,theta = 0.75,
#' rangeb = 0.2, rangew = 0.05, R = 1, r1 = 0.47,corr = TRUE, ICC = 0.5, s = 1.25)
#' result3 <- sampleSize_MRMC(endpoint = 'se',J = 15, delta = 0.05, theta = 0.75,
#' rangeb = 0.2, rangew = 0.025, R = 1, r1 = 0.5, corr = TRUE, ICC = 0.5, s = 1.25)
#' @export

sampleSize_MRMC <- function(endpoint = "auc",
                            J,
                            delta,
                            rangeb,
                            rangew,
                            theta,
                            R = 1,
                            r1,
                            r2 = 0.3,
                            r3 = 0.3,
                            rb = 0.8,
                            K = 1,
                            power = 0.8,
                            alpha = 0.05,
                            nu1 = 1,
                            var_auc = "obuchowski",
                            reader_var_estimation_method = 'normal',
                            n_reading_sessions_per_reader = 2,
                            corr = FALSE,
                            ICC = NULL,
                            s = NULL){

  if (J < 5) {warning("Number of readers < 5 is not recommended for an MRMC study.")}
  if (delta > 0.50 & delta < 1) {warning("Effect size seems to be very large. Are you sure to power the study for such a large effect size?")}
  if (theta >= 1 | theta <=0) {stop("The conjectured 'theta' value does not seem probable. It has to be a numeric value 0 < theta < 1")}
  if (delta > 1 | delta <= 0) {stop("Improbable delta value. It has to be numeric value 0 < delta < 1")}
  if (! ((rangeb > 0 & rangeb < 1)  &
         (rangew > 0 & rangew < 1)  &
         (r1 > 0 & r1 < 1) &
         (r2 > 0 & r2 < 1) &
         (r3 > 0 & r3 < 1) &
         (rb > 0 & rb < 1) &
         (R > 0) ))
    {stop("Invalid correlation values or reader variability ranges or ratio found!")}




  if(tolower(reader_var_estimation_method) == 'normal'){
    f <- function(x) J*x*stats::pnorm(x)^(J-1)*stats::dnorm(x)
    c1 <- 1/(2*stats::integrate(f,-Inf,Inf)$value) #constant for estimating sb
    sb <- rangeb*c1 ##inter-reader sd
    S <- n_reading_sessions_per_reader
    f <- function(x) S*x*stats::pnorm(x)^(S-1)*stats::dnorm(x)
    c2 <- 1/(2*stats::integrate(f,-Inf,Inf)$value) #constant for estimating sw
    sw <- rangew*c2 #intra-reader sd

  } else{
    #print("Using the relationship between sd and range to estimate sd: sd = range/4...")
    sb <- rangeb/4
    sw <- rangew/4
  }

  lambda <- ncparamF(alpha, 1-power, nu1 = nu1, nu2 = nu1*(J-1)) #ndf (nu1) is always number of treatments - 1.

  varTR <- sb^2*(1-rb)
  varR <- sb^2
  varW <- sw^2
  num <- ((J*delta^2)/ (2*lambda)) -  (varTR + sw^2/K)
  den <- (1-r1) + (J-1)*(r2-r3)

  sigma.square.c = num/den

  varE <-  sigma.square.c + sw^2
  Cov1 <- r1*varE
  Cov2 <- r2*varE
  Cov3 <- r3*varE


  if(sigma.square.c <=0){stop("Number of readers (J) are not enough to power the MRMC study for the given assumptions. Increase J and re-estimate the sample size OR be less conservative in the current assumptions")}

  if(tolower(endpoint) %in% c("se", "sens", "sensitivity") | var_auc == "blume"){
    var.theta= theta*(1-theta) #variance calculation for Se
  }else if(tolower(endpoint) %in% c("auc") & var_auc == "obuchowski"){
    A <-  stats::qnorm(theta)*1.414
    var.theta <- ((0.0099 * exp(-A^2/2)) * ( (5*A^2 +8) + (A^2 +8)/R)) #Obuchowski NA. Computing sample size for receiver operating characteristic studies. Invest Radiol. 1994;29(2):238-243. doi:10.1097/00004424-199402000-00020
  }else{
    stop("Endpoint has to be either 'Sensitivity' or 'AUC'")
  }

  nUnits_i = ceiling(var.theta/sigma.square.c)
  n.total <- ceiling(nUnits_i*(1+R))



  METHOD1 <- "OR Variance Components"
  NOTE1 <- paste0("\n",
                  "varTR: Var(T*R), the estimated variance of the interaction between reader and test", "\n",
                  "varE: Var(E), the estimated variance of estimated accuracy of a reader due to both intrareader variability and patient sample variability", "\n",
                  "varR: Var(R), the inter-reader variance estimated from rangeb", "\n",
                  "varW: Var(W), the intra-reader variance estimated from rangew", "\n",
                  "Cov1: Covariance between accuracies estimated from the same sample of patients by the same reader using different imaging techniques", "\n",
                  "r1: Correlation corresponding to Cov1", "\n",
                  "Cov2: Covariance between accuracies estimated from the same sample of patients by different readers using the same imaging technique", "\n",
                  "r2: Correlation corresponding to Cov2", "\n",
                  "Cov3: Covariance between accuracies estimated from the same sample of patients by different readers using different imaging techniques", "\n",
                  "r3: Correlation corresponding to Cov1", "\n")


  out1 <- structure(list(varTR = varTR,
                         varE = varE,
                         varR = varR,
                         varW = varW,
                         Cov1 = Cov1,
                         r1 = r1,
                         Cov2 = Cov2,
                         r2 = r2,
                         Cov3 = Cov3,
                         r3 = r3,
                         method = METHOD1, note = NOTE1), class = "power.htest")


  if (!corr){
    text <- "Not applicable"
    nUnits_i <- nUnits_i
    nCases_c <- NA
    nControls = ceiling(nUnits_i*R)
    nTotal <- nUnits_i + nControls
    de <- NA
    s <- NA
    if (nUnits_i < 10) {warning("Number of required diseased cases is coming out to be < 10. It is not typically recommended to conduct MRMC study with less than 10 cases. Consider increasing the sample size to minimum 10 diseased cases.")}
  } else {
    if(is.null(ICC) | is.null(s)) {stop("ICC and s must be valid numeric values to take correlation within diseased cases into account")}
    text <- "Intra-class correlation applicable"
    nUnits_i <- nUnits_i
    de = 1 + (s-1)*ICC
    nUnits_c = ceiling(nUnits_i * de)
    nCases_c = ceiling(nUnits_c/s)
    nControls = ceiling(nCases_c*R)
    nTotal = nCases_c + nControls
    s <- s
    if (nUnits_c < 10) {warning("Number of required diseased cases is coming out to be < 10. It is not typically recommended to conduct MRMC study with less than 10 cases. Consider increasing the sample size to minimum 10 diseased cases.")}

  }


  METHOD2 <- "Obuchowski-Rockette Sample Size Estimation Results"

  NOTE2 <- paste0("\n",
                  "ICC: Is intra-cluster correlation (ICC) considered while estimating sample size?", "\n",
                  "nUnits_i: Number of required units (a unit is a lesion of interest) assuming independence between units", "\n",
                  "nCases_c: Number of required diseased cases with presence of at least one unit of lesion after adjusting for ICC", "\n",
                  "nControls: Number of required non-diseased cases", "\n",
                  "nTotal: Total sample size (cases)", "\n",
                  "J: Number of readers", "\n",
                  "DE: Design effect due to ICC", "\n",
                  "s: Assumed average number of lesions in diseased cases", "\n",
                  "power: Assumed power", "\n",
                  "alpha: Significance level (Type I error rate)", "\n"
  )

  out2 <- structure(list(ICC = text,
                         nUnits_i = nUnits_i,
                         nCases_c = nCases_c,
                         nControls = nControls,
                         nTotal = nTotal,
                         J = J,
                         DE = de,
                         s = s,
                         power = power,
                         alpha = alpha,
                         method = METHOD2, note = NOTE2), class = "power.htest")

  out <- list("varComponents" = out1, "ORSampleSizeResults" = out2)
  return(out)
}
