library(dplyr)
library(ggplot2)
data("ChickWeight")

# in this script:
    # Plotting aggregate time-series data
    # Plotting unaggregated time-series data; highlighting by 2 factors

# Plot mean chick weight for two diets over time:

  ## Base R + error bars
my.data <- aggregate(weight ~ Time + Diet, data = ChickWeight, mean)
se.weight <- sd(my.data$weight)/sqrt(length(my.data$weight) - 1)

ggplot(data = my.data) + 
    aes(y = weight, x = Time, col = as.factor(Diet)) + 
    geom_point() + 
    geom_line() +  
    geom_errorbar(aes(
        ymin = weight - se.weight, 
        ymax = weight + se.weight),
        width = 0.2)


  ## dplyr + Ribbons
chk <- ChickWeight %>%
    group_by(Diet, Time) %>%
    summarize(weight = mean(weight), se.weight = se.weight)

ggplot(chk, aes(x = Time)) + 
    geom_line(
        aes(y = weight, 
            color = Diet), 
        size = 0.75) +
    geom_ribbon(
        aes(ymin = weight - se.weight, 
            ymax = weight + se.weight, 
            fill = Diet), 
        alpha = 0.2)



# Plot all chick weights over time; represent different diets with different colours

# I want to show all of the data, but I want to highlight chicks that are in diet 1, while all of the other diets are in grey or something.


ggplot(data = ChickWeight) +
    geom_point(aes(y = weight,
                   x = Time,
                   col = as.factor(ifelse(Diet == 1, 2, 1))),
               alpha = 0.3) +
    geom_line(aes(y = weight,
                  x = Time,
                  group = interaction(Chick, Diet),
                  col = as.factor(ifelse(Diet == 1, 2, 1))),
              alpha = 0.3) +
    scale_colour_manual(values = c("grey", "red"))
