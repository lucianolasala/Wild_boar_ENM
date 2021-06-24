
library(kuenm)
library(Rcpp)

# 1. Creation of candidate models
kuenm_cal_swd(occ.joint = "Boars_SWD_joint.csv",
              occ.tra = "Boars_SWD_train.csv",
              occ.test = "Boars_SWD_test.csv",
              back.dir = "Boars_background",
              batch = "Candidate_models",
              out.dir.models = "Candidate_models",
              reg.mult = c(0.1, 0.25, 0.5, 0.75, 1, 2.5, 5),
              f.clas = "basic",
              max.memory = 1000,
              args = "maximumbackground=11000",
              maxent.path = ".",
              selection = "OR_AICc",
              threshold = 5,
              rand.percent = 50,
              iterations = 1,
              kept = TRUE,
              out.dir.eval = "Candidate_models_eval")


kuenm_mod_swd(occ.joint = "Boars_SWD_joint.csv",
              back.dir = "Boars_background",
              out.eval = "Candidate_models_eval",
              batch = "Final_models",
              rep.n = 5,
              rep.type = "Bootstrap",
              out.format = "cloglog",
              jackknife = FALSE,
              write.mess = TRUE,
              write.clamp = TRUE,
              maxent.path ="/home/sjor/julian/Boars_kuenm",
              out.dir = "Final_models",
              project = FALSE)

kuenm_mod_swd(occ.joint = "Boars_SWD_joint.csv",
              back.dir = "Boars_background",
              out.eval = "Candidate_models_eval",
              batch = "Final_models2",
              rep.n = 5,
              rep.type = "Bootstrap",
              out.format = "cloglog",
              jackknife = FALSE,
              write.mess = TRUE,
              write.clamp = TRUE,
              maxent.path ="/home/sjor/julian/Boars_kuenm",
              out.dir = "Final_models2",
              project = TRUE,
              G.var.dir="/home/sjor/julian/Boars_kuenm/G_variables")


# kuenm_mmop
