library(ggrepel)
library(adegenet)
library(tidyverse)

mcglPCA = function(dat) {
  x <- tab(dat,
           freq = TRUE,
           NA.method = "mean")

  pca <- dudi.pca(
    x,
    center = TRUE,
    scale = FALSE,
    nf = 4,
    scannf = FALSE
  )

  popNames <- dat@pop %>%
    as_tibble() %>%
    rename(pop = value)

  pca.df <- pca$li %>%
    as_tibble() %>%
    mutate(pop = popNames$pop)

  centroids <- pca.df %>%
    select(pop) %>%
    right_join(aggregate(cbind(Axis1, Axis2) ~ pop,
                         pca.df,
                         mean)) %>%
    distinct(.keep_all = TRUE)

  ggplot(pca.df,
         aes(x = Axis1,
             y = Axis2,
             color = pop)) +
    geom_point(alpha = 0.4) +
    stat_ellipse() +
    geom_point(data = centroids,
               size = 6,
               alpha = 0.8) +
    geom_text_repel(
      data = centroids,
      fontface = "bold",
      aes(label = pop),
      size = 5,
      force = 5,
      force_pull = 0.1,
      max.overlaps = 100
    ) +
    ylab("Axis 2") +
    xlab("Axis 1") +
    theme_classic(base_size = 18) +
    theme(legend.position = "none") +
    NULL
}
