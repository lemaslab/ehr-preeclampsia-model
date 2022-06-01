```{r}
# eope baseline model validation

library(glmnet)
library(survival)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(survminer)
# load UF validation set 
df = mydata
df = df%>%select(diag_GA, SeverePE, past_pe, EPIS_PARA_COUNT, Coagulopathy, 
                 PulmonaryCirculationDisorders, RaceName.African.American, time_to_deliver)

# convert zeros in time_to_deliver to 0.5
for(i in c(1:nrow(df))){
  if(df$time_to_deliver[i] == 0){
    df$time_to_deliver[i] = 0.5
  }
}


for(i in c(1:7)){
  df[,i] = scale(df[,i], center = F)
}


xtest = data.matrix(df%>%dplyr::select(-time_to_deliver))
ytest = df%>%dplyr::select(time_to_deliver)
ytest = data.frame(time = ytest, status = rep(1, length(ytest)))
colnames(ytest)[1] = "time"

#calculate c-index for cox-ph using pre-trained model
load("coxph_eope_model0510.RData") 
test_ridge <- predict(train_ridge, xtest ,s=train_ridge$lambda.min,type='link')
cindex_ridge <- round(Cindex(test_ridge, ytest),3)
cindex_ridge

# plot the predicted vs true value scatterplot
result = data.frame(test_ridge, ytest[,1])
colnames(result) = c("Predicted", "True")
p_result = ggplot(result, aes(x = Predicted, y=True))+geom_point(col = "steelblue", size=0.5)+
  annotate("text",x=max(result$Predict)-1, y=max(result$True),label = sprintf("c-index:%f", cindex_ridge))
p_result

# plot KM curves
High_risk = ifelse(result$Predicted>median(result$Predicted), T, F)
result$high_risk = High_risk
cox = survfit(Surv(True, rep(1, nrow(result)))~high_risk, data = result)
eope_km = ggsurvplot(cox, result, conf.int = T, pval = T, pval.method = T, pval.size = 4, pval.coord = c(70, 0.7), pval.method.coord = c(70, 0.8),
                     font.x = 12,font.y = 12, font.tickslab=12, font.title = 9, font.legend = 12,xlab = NULL)
eope_km

result$risk = rep(NA, nrow(result))
for(i in 1:nrow(result)){
  if(result$Predicted[i] > quantile(result$Predicted, probs = 0.75)){
    result$risk[i] = "High"
  }else if(result$Predicted[i] < quantile(result$Predicted, probs = 0.25)){
    result$risk[i] = "Low"
  }else{
    result$risk[i] = "Middle"
  }
}

cox2 = survfit(Surv(True, rep(1, nrow(result)))~risk, data = result)
eope_km2 = ggsurvplot(cox2, result, conf.int = T, pval = T, pval.method = T, pval.size = 4, pval.coord = c(70, 0.7), pval.method.coord = c(70, 0.8),
                      font.x = 12,font.y = 12, font.tickslab=12, font.title = 9, font.legend = 12,xlab = NULL)
eope_km2

# build coxph full model
# x_train = as.matrix(df%>%dplyr::select(-time_to_deliver))
# y_train = df%>%dplyr::select(time_to_deliver)
# y_train = data.frame(time = y_train, status = rep(1, length(y_train)))
# colnames(y_train)[1] = "time"
# y_train = as.matrix(y_train)
# 
# train_ridge <-cv.glmnet(x_train, y_train, nfolds = 5, family = "cox", alpha = 0)
# coef(train_ridge)
# train_theta = predict(train_ridge, x_train, s=train_ridge$lambda.min,type='link')
# cindex_ridge_train = Cindex(train_theta, y_train)
# cindex_ridge_train
# save(train_ridge,file = "eope_baseline0531.RData")

```