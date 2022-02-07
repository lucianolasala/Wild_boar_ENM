***
#### Packages and libraries

```r
if(!require(devtools)){
  install.packages("devtools")
}
if(!require(kuenm)){
  devtools::install_github("marlonecobos/kuenm")
}

library(kuenm) # An R package for detailed development of ecological niche models
using Maxent

install.packages("Rcpp")
library(Rcpp)  # Seamless R and C++ integration
```

#### Creation of candidate models
>The function *kuenm_cal_swd* performs the whole process of model calibration (i.e., candidate model creation and evaluation) using Maxent in SWD format. Models are created with multiple parameter combinations, including distinct regularization multiplier values, various feature classes, and different sets (one in this work) of environmental variables represented by csv files that contain the background. Evaluation is done in terms of statistical significance (partial ROC), prediction ability (omission rates), and model complexity (AICc). After evaluation, this function selects the best models based on user-defined criteria. 

```r
set.seed(100)
kuenm_cal_swd(occ.joint = "Boars_SWD_joint.csv",
              occ.tra = "Boars_SWD_train.csv",
              occ.test = "Boars_SWD_test.csv",
              back.dir = "M_variables",
              batch = "Candidate_models",
              out.dir.models = "Candidate_models",
              reg.mult = c(0.1, 0.25, 0.5, 0.75, 1, 2.5, 5),
              f.clas = "basic",
              max.memory = 1000,
              maxent.path = ".",
              selection = "OR_AICc",
              threshold = 5,
              rand.percent = 50,
              out.dir.eval = "Candidate_models_eval",
              kept = TRUE)
```

#### Model projection

```r
set.seed(100)

kuenm_mod_swd(occ.joint = "Boars_SWD_joint.csv",
              back.dir = "M_variables",
              out.eval = "Candidate_models_eval",
              batch = "Final_models",
              rep.n = 10,
              rep.type = "Bootstrap",
              out.format = "cloglog",
              jackknife = TRUE,
              write.mess = TRUE,
              write.clamp = TRUE,
              maxent.path = "D:/LFLS/Analyses/Jabali_ENM/Modelado_5/",
              out.dir = "Final_models",
              project = TRUE,
              G.var.dir = "G_variables")



