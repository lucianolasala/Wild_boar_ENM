***
>Installation of packages

```r
library(kuenm) # An R package for detailed development of ecological niche models
using Maxent
library(Rcpp)  # Seamless R and C++ integration
```

#### Creation of candidate models

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


