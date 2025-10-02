

library(ggplot2)
library(tidyr)
library(webr)
library(dplyr)
library(stringr)

#	NEED THE FULL PATH SINCE THIS IS RUN IN /scratch
df=read.csv( "hla-cidr-hg19/chr6.hla_dosage.csv", sep="\t", header=TRUE)

df$AF <- NULL
df$R2 <- NULL

rownames(df)=df[[colnames(df)[1]]]
df[[colnames(df)[1]]]=NULL
df[0:9,0:9]

row_sums <- data.frame(sum = rowSums(df, na.rm = TRUE) )
row_sums$hla3 = rownames(row_sums)
row_sums

hla_abc = row_sums[grepl("^HLA_[ABC].*:", rownames(row_sums)), ]
head(hla_abc)

split_names <- str_split_fixed(hla_abc$hla3, ":", 2)
hla_abc$hla2 <- split_names[, 1]
split_names <- str_split_fixed(hla_abc$hla3, "\\*", 2)
hla_abc$hla1 <- split_names[, 1]
head(hla_abc)

p0 <- mutate(hla_abc, top_level = hla1)
p1 <- pivot_longer(p0, cols = c(hla1, hla2, hla3))
p2 <- group_by(p1, name, value)
p3 <- mutate(p2, width = sum(sum))
p3$sum <- NULL
p4 <- unique(p3)
p5 <- arrange(p4, value) # ?
p6 <- group_by(p5, name)

p7 <- mutate(p6, ymid = as.numeric(sub("\\D+", "", name)),
         ymax = ymid + 0.5, ymin = ymid - 0.5,
         xmin = c(0, head(cumsum(width), -1)),
         xmax = cumsum(width),
         xmid = (xmax + xmin) / 2)

p7


