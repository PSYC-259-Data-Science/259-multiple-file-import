library(randomForest)
library(randomForestExplainer)
library(dplyr)
library(caret)
library(reprtree)
library(readr)

ds <- read_csv("classification.txt")
ds$time <- as.numeric(row.names(ds))

# ds = subset(ds, ds$class_prop == 1 | ds$half == 1) #Only full windows for training
# ds = subset(ds, ds$class_prop == 1) #Only full windows for both
ds = subset(ds, ds$class %in% c(3,5,6,7,9,10)) #Only classes with enough data
ds$classe <- ds$class
ds = subset(ds, select = -c(1,2,3) )
ds$classe <- factor(ds$classe,levels = c(3,5,6,7,9,10),labels = c("prone", "held_walk","held_stat","sit_surf","sit_rest","supine"))


intrain <- createDataPartition(y = ds$classe, p = .65, list = FALSE)
training <- ds[intrain,]
testing <- ds[-intrain,]

# training <- subset(ds, ds$half == 0)
# testing <- subset(ds, ds$half == 1)

rfmodel <- randomForest(classe ~ ., data = training, localImp = TRUE, proximity = TRUE,na.action=na.roughfix, ntree = 50)
predictions <- predict(rfmodel, testing, type = "class")
confusionMatrix(table(predictions, testing$classe))

min_depth_frame <- min_depth_distribution(rfmodel)
plot_min_depth_distribution(min_depth_frame,15)

importance_frame <- measure_importance(rfmodel)
plot_multi_way_importance(importance_frame, size_measure = "no_of_nodes")
plot_multi_way_importance(importance_frame, size_measure = "p_value")
plot_importance_ggpairs(importance_frame)

(vars <- important_variables(importance_frame, k = 5, measures = c("mean_min_depth", "no_of_trees")))
interactions_frame <- min_depth_interactions(rfmodel, vars)
plot_min_depth_interactions(interactions_frame)

plot_predict_interaction(rfmodel, rol_win, "p1_mean", "p1_kurtosis")

reprtree:::plot.getTree(rfmodel)

classCenter(rol_win[,-1],rol_win[,1],rfmodel$proximity)

testing$predictions <- predictions
output <- select(testing, c("classe","predictions"))
output$classe <- as.numeric(output$classe)
output$predictions <- as.numeric(output$predictions)
write.table(output, file = "predictions1-599.csv")
