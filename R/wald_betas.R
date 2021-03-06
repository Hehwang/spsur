#' @name wald_betas
#' @rdname wald_betas
#'
#'
#'
#' @title Wald tests on the \emph{beta} coefficients of the equation of the SUR model
#'
#'
#' @description
#' The function \code{\link{wald_betas}} can be seen as a complement to the restricted estimation procedures
#' included in the functions \code{\link{spsurml}} and \code{\link{spsur3sls}}. \code{\link{wald_betas}}
#' obtains Wald tests for sets of linear restrictions on the coefficients \eqn{\beta} of the SUR model.
#' The restrictions may involve coefficients of the same equation or coefficients from different
#' equations. The function has great flexibility in this respect. Note that \code{\link{wald_betas}}
#' is more general than \code{\link{lr_betas_spsur}} in the sense that the last function
#' only allows to test for restrictions of homogeneity of subsets of \eqn{\beta} coefficients among
#' the different equations in the SUR model, and in a maximum-likelihood framework.
#'
#'  In order to work with \code{\link{wald_betas}}, the model on which the linear restrictions are
#'  to be tested needs to exists as an \emph{spsur} object.  Using the information contained in the object,
#'  \code{\link{wald_betas}} obtains the corresponding Wald estatistic  for the null hypotheses
#'  specified by the user through the \emph{R} row vector and \emph{b} column vector, used also in
#'  \code{\link{spsurml}} and \code{\link{spsur3sls}}. The function shows the value of the Wald test
#'  statistics and its associated p-values.
#'
#'
#' @param    results : An object created with \code{\link{spsurml}} or \code{\link{spsur3sls}}. This argument
#'  serves the user to indicate the spatial SUR model, previously estimated by maximum-likelihood or 3sls,
#'  where the set of linear restrictions are to be tested.
#' @param    R       : A row vector of order \eqn{(1xPr)} showing  the set of \emph{r} linear constraints
#'  on the \eqn{\beta} parameters. The \emph{first} restriction appears in the first \emph{K} terms in \emph{R},
#'  the \emph{second} restriction in the next \emph{K} terms and so on. Default = NULL.
#' @param    b       : A column vector of order \emph{(rx1)} with the values of the linear restrictions
#' on the \eqn{\beta} parameters.
#'
#'
#' @return
#' The output of the function is very simple and consists of two pieces of information, the value of the Wald
#' statistic and the corresponding p-value, plus the degrees of freedom of the test.
#'
#'   \tabular{ll}{
#'   \code{Wald stat} \tab The value of Wald test. \cr
#'   \code{p_val}    \tab The p-value of Wald test. \cr
#'   \code{q}    \tab Degrees of freedom of the corresponding \eqn{\chi^{2}} distribution. \cr
#'   }
#'
#' @author
#'   \tabular{ll}{
#'   Fernando López  \tab \email{fernando.lopez@@upct.es} \cr
#'   Román Mínguez  \tab \email{roman.minguez@@uclm.es} \cr
#'   Jesús Mur  \tab \email{jmur@@unizar.es} \cr
#'   }
#
#'
#' @references
#'   \itemize{
#'     \item López, F.A., Mur, J., and Angulo, A. (2014). Spatial model
#'        selection strategies in a SUR framework. The case of regional
#'        productivity in EU. \emph{Annals of Regional Science}, 53(1), 197-220.
#'     \item López, F.A., Martínez-Ortiz, P.J., & Cegarra-Navarro, J.G. (2017).
#'        Spatial spillovers in public expenditure on a municipal level in
#'        Spain. \emph{Annals of Regional Science}, 58(1), 39-65.
#'     \item Mur, J., López, F., and Herrera, M. (2010). Testing for spatial
#'       effects in seemingly unrelated regressions. \emph{Spatial Economic Analysis}, 5(4), 399-440.
#'   }
#'
#'
#' @seealso
#'  \code{\link{spsurml}}, \code{\link{spsur3sls}}, \code{\link{lr_betas_spsur}}
#'
#' @examples
#'
#' #################################################
#' ######## CROSS SECTION DATA (G=1; Tm>1) ########
#' #################################################
#'
#' #### Example 1: Spatial Phillips-Curve. Anselin (1988, p. 203)
#' rm(list = ls()) # Clean memory
#' data(spc)
#' Tformula <- WAGE83 | WAGE81 ~ UN83 + NMR83 + SMSA | UN80 + NMR80 + SMSA
#' ## Estimate SUR-SLM model
#' spcsur.slm <- spsurml(Form = Tformula, data = spc, type = "slm", W = Wspc)
#' summary(spcsur.slm)
#' ## H_0: equality between SMSA coefficients in both equations.
#' R1 <- matrix(c(0,0,0,1,0,0,0,-1), nrow=1)
#' b1 <- matrix(0, ncol=1)
#' Wald_beta <- wald_betas(results = spcsur.slm, R = R1, b = b1)
#'
#' ## H_0: equality between intercepts and SMSA coefficients in both equations.
#' R2 <- matrix(c(1,0,0,0,-1,0,0,0,0,0,0,1,0,0,0,-1),
#'              nrow = 2, ncol = 8, byrow = TRUE)
#' b2 <- matrix(c(0,0),ncol=1)
#' wald_betas(results = spcsur.slm, R = R2, b = b2)
#'
#' ####################################
#' ########  G=1; Tm>1         ########
#' ####################################
#'
#' #### Example 2: Homicides + Socio-Economics (1960-90)
#' data(NCOVR)
#' Tformula <- HR80  | HR90 ~ PS80 + UE80 | PS90 + UE90
#' #################################
#' ## A SUR-SLM model
#' NCOVRSUR.slm <-spsurml(Form = Tformula, data = NCOVR, type = "slm", W = W)
#' summary(NCOVRSUR.slm)
#' R1 <- matrix(c(0,1,0,0,-1,0), nrow=1)
#' b1 <- matrix(0, ncol=1)
#' wald_betas(results = NCOVRSUR.slm, R = R1, b = b1)
#' @export
 wald_betas <- function(results , R , b){
  z <- results # OBJETO QUE INCLUYE ESTIMACIÓN EN Rbetas <- z$betas
  betas <- Matrix::Matrix(matrix(z$betas,ncol=1))
  rownames(betas) <- names(z$betas)
  cov_betas <- Matrix::Matrix(z$cov[rownames(betas),rownames(betas)])
  R <- Matrix::Matrix(R)
  colnames(R) <- rownames(betas)
  b <- Matrix::Matrix(matrix(b,ncol=1))
  holg <- R %*% betas - b
  q <- nrow(as.matrix(R))
  Wald <- as.numeric( Matrix::t(holg) %*%
                Matrix::solve(R %*% cov_betas %*% Matrix::t(R),holg) )
  p_val <- pchisq(Wald,df=q,lower.tail=FALSE)
  # cat("\n statistical discrepancies: "); print(as.matrix(holg))
  cat("Wald stat.: ",round(Wald,3)," p-value: (",round(p_val,3),") \n",
       sep = "")
  res <- list(stat = Wald,
              p_val = p_val,
              q = q,
              R = as.matrix(R),
              b = as.matrix(b),
              discr = as.matrix(holg) )
}
