

data = data.frame(
  model =c("Naive Bayes","Llama 3","LSTM","Regex","Llama 3 + GCA","GPT 4","GPT 4 + GCA"),
  Precision = c(0.08,0.32,0.49,0.46,0.83,0.61,0.84),
  Recall = c(0.72,0.70,0.46,0.70,0.11,0.97,0.85)
)


# Reshape the data to a long format
data_long <- reshape2::melt(data, id.vars = "model", variable.name = "Metric", value.name = "Value")

data_long$model = factor(data_long$model, levels=c("Regex","Naive Bayes","LSTM","Llama 3","Llama 3 + GCA","GPT 4","GPT 4 + GCA"))

library(ggplot2)

# Adjust y-axis labels and breaks
ggplot(data_long, aes(x = model, y = ifelse(Metric == "Precision", Value * 2, -Value), fill = Metric)) +
  geom_bar(stat = "identity", position = "identity", width = 0.5) +
  scale_y_continuous(labels = function(x) ifelse(x < 0, abs(x), x / 2), breaks = seq(-1, 3, by = 1),limits=c(-1,2)) +
  labs(x = "Model", y = "Value") +
  scale_fill_manual(values = c("Precision" = "#32CD32", "Recall" = "#AAFFFF")) +
  theme_minimal() +
  theme(
    axis.title.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16),
    plot.title = element_text(size = 18),
    plot.subtitle = element_text(size = 16),
    plot.caption = element_text(size = 12)
  )
