#### Extrapolation Risk Analysis
The *kuenm_mmop* function calculates mobility-oriented parity (MOP) layers by comparing environmental values between the calibration area and one or multiple regions or scenarios to which ecological niche model were transferred (here, ecorregions without wild boar records). The layers produced with this function help to visualize were strict extrapolation risks exist, and different similarity levels between the projection regions or scenarios and the calibration area. 

``` r
kuenm_mmop(G.var.dir = "G_variables",
           M.var.dir = "M_variables",
           is.swd = TRUE,
           sets.var = c("Set_1"),
           out.mop = "mop_results",
           percent = 50,
           comp.each = 2000,
           parallel = FALSE)
