#!/usr/bin/env Rscript












# Z score visualization via Manhattan plot 
library(ggplot2)
library(gridExtra)

# working directory
#mwd = "/Users/gguerra/Library/CloudStorage/Box-Box/Francis _Lab_Share/20240925-Illumina-PhIP/20240925c-PhIP/processed_separately_by_condition"
mwd = "/Users/gguerra/Library/CloudStorage/Box-Box/Francis _Lab_Share/20240925-Illumina-PhIP/20241009-PhIP/processed_separately"

# Read in each of the files
# Note Jake annotated these files to include the viral species as a column. 
counts_1 =read.csv(paste(mwd, "/1.count.Zscores.species_peptides.Zscores.csv", sep =""), header= TRUE, sep = ",")
counts_2 =read.csv(paste(mwd, "/2.count.Zscores.species_peptides.Zscores.csv", sep =""), header= TRUE, sep = ",")
counts_3 =read.csv(paste(mwd, "/3.count.Zscores.species_peptides.Zscores.csv", sep =""), header= TRUE, sep = ",")
counts_4 =read.csv(paste(mwd, "/4.count.Zscores.species_peptides.Zscores.csv", sep =""), header= TRUE, sep = ",")

# This simply needs to be a list of peptides to work. Just need to know which peptides are deemed as "Public Epitopes"
public_eps = read.csv(paste(mwd, "/3.public_epitope_annotations.Zscores.csv", sep = ""), header = TRUE, sep = ",")
public_ep_id = public_eps$id

# Matching and testing to ensure all files contain the same rows
c12 = intersect(counts_1$id, counts_2$id)
c123 = intersect(counts_3$id,c12)
c_all = intersect(counts_4$id, c123)


# Join all data together into a single file (first three columns are info (id, species, peptide seq), rest are the triplicate z-scores)
counts_all = cbind(
	counts_1[which(counts_1$id %in% c_all), c(1,2,3)],
	counts_1[which(counts_1$id %in% c_all), c(4,5,6)],
	counts_2[which(counts_2$id %in% c_all), c(4,5,6)],
	counts_3[which(counts_3$id %in% c_all), c(4,5,6)],
	counts_4[which(counts_4$id %in% c_all), c(4,5,6)])


# Viruses interested in investigating
my_viruses = c("Human herpesvirus 1", "Human herpesvirus 2", "Human herpesvirus 3", "Human herpesvirus 4", "Human herpesvirus 5")

# Identify the rows which match these viruses, so we can work with a much smaller dataframe. 
hvs = which(counts_all$Species %in% c("Human herpesvirus 1", "Human herpesvirus 2", "Human herpesvirus 3", "Human herpesvirus 4", "Human herpesvirus 5"))

counts_sub = counts_all[hvs,]

#write.table(counts_sub, file=paste(mwd, "/herpesviruses_Zscores_1_2_3_4.csv", sep = ""), quote = FALSE, row.names = FALSE, col.names = TRUE, sep = ",")

counts_sub$Public =0

# Flag the public epitopes so we can plot them using a different color/shape later. 
counts_sub$Public[which(counts_sub$id %in% public_ep_id)] = 1
counts_sub$Public = as.factor(counts_sub$Public)


# This just maps each Individual to their samples. In this case there are 3 samples/replicates per "individual"
conditions = list()
conditions[[1]] = c("L1", "L2", "L3")
conditions[[2]] = c("L7", "L8", "L9")
conditions[[3]] = c("L13", "L14", "L15")
conditions[[4]] = c("L19", "L20", "L21")



# Viral Plotter scripts, print the plots to pdf, one virus per page. 


# Plotting the MAXIMUM Z-score across the replicates for each peptide, and creating separate plots for each individual.
viral_plotfile =paste(mwd,"/Mean_Z-score_plots_by_condition_max25.pdf", sep = "")
pdf(viral_plotfile, width = 7, height=8, onefile = TRUE)
for(virus in my_viruses){
	print(virus)
	subdf = counts_sub[which(counts_sub$Species == virus),]
	subdf$index = c(1:nrow(subdf))
	plots = list()
	for(cond in c(1:4)){
		subdf$means= NA
		for(t in c(1:nrow(subdf))){
			subdf$means[t] = mean(as.numeric(subdf[t, which(colnames(subdf) %in% conditions[[cond]])]))
		}
		# Simply to keep the y-axis from exploding, the Z-score is just "high" at this point. 
		subdf$means[which(subdf$means >20)]= 20
		# Z-scores can be negative, but since this is ultimately a one-sided test interested in high z scores, we can just recode to 0. 
		subdf$means[which(subdf$means <0 )]= 0

		plots[[cond]] = ggplot(subdf, aes(x=index, y=means, color=Public, shape = Public, size =Public)) +
			geom_point()+ 
			scale_color_manual(values=c('grey80','red')) +
			scale_size_manual(values = c(2, 4))+
			theme_classic()+ 
			theme(legend.position = "none")  +
			labs(title=paste("Condition ", cond, sep = ""), x="", y = "Mean Z-score") +
			geom_hline(yintercept = 3.5, linetype="dashed", color = "blue") +ylim(c(0,25))+
			geom_hline(yintercept = 10, linetype="dashed", color = "gold") 
	}

	# Arrange the 4 plots (4 individuals) into a single window. 
	myplot = grid.arrange(plots[[1]], plots[[2]], plots[[3]], plots[[4]], ncol=1, top = paste(virus, " (Dashed lines are Z =3.5 and 10, Public Epitopes in Red)", sep =""))
	print(myplot)
}
dev.off()

# Plotting the MEDIAN Z-score across the replicates for each peptide, and creating separate plots for each individual.
viral_plotfile =paste(mwd,"/Median_Z-score_plots_by_condition_max25.pdf", sep = "")
pdf(viral_plotfile, width = 7, height=8, onefile = TRUE)
for(virus in my_viruses){
	print(virus)
	subdf = counts_sub[which(counts_sub$Species == virus),]
	subdf$index = c(1:nrow(subdf))
	plots = list()
	for(cond in c(1:4)){
		subdf$means= NA
		for(t in c(1:nrow(subdf))){
			subdf$means[t] = median(as.numeric(subdf[t, which(colnames(subdf) %in% conditions[[cond]])]))
		}

		subdf$means[which(subdf$means >20 )]= 20
		subdf$means[which(subdf$means <0 )]= 0

		plots[[cond]] = ggplot(subdf, aes(x=index, y=means, color=Public, shape = Public, size =Public)) +
			geom_point()+ 
			scale_color_manual(values=c('grey80','red')) +
			scale_size_manual(values = c(2, 4))+
			theme_classic()+ 
			theme(legend.position = "none")  +
			labs(title=paste("Condition ", cond, sep = ""), x="", y = "Median Z-score") +
			geom_hline(yintercept = (3.5), linetype="dashed", color = "blue") +ylim(c(0,25)) +
			geom_hline(yintercept = (10), linetype="dashed", color = "gold") 
	}

	myplot = grid.arrange(plots[[1]], plots[[2]], plots[[3]], plots[[4]], ncol=1, top = paste(virus, " (Dashed lines are Z =3.5 and 10, Public Epitopes in Red)", sep =""))
	print(myplot)
}
dev.off()


# Plotting the MINIMUM Z-score across the replicates for each peptide, and creating separate plots for each individual.
viral_plotfile =paste(mwd,"/Minimum_Z-score_plots_by_condition_max25.pdf", sep = "")
pdf(viral_plotfile, width = 7, height=8, onefile = TRUE)
for(virus in my_viruses){
	print(virus)
	subdf = counts_sub[which(counts_sub$Species == virus),]
	subdf$index = c(1:nrow(subdf))
	plots = list()
	for(cond in c(1:4)){
		subdf$means= NA
		for(t in c(1:nrow(subdf))){
			subdf$means[t] = min(as.numeric(subdf[t, which(colnames(subdf) %in% conditions[[cond]])]))
		}

		subdf$means[which(subdf$means >20 )]= 20
		subdf$means[which(subdf$means <0 )]= 0

		plots[[cond]] = ggplot(subdf, aes(x=index, y=means, color=Public, shape = Public, size =Public)) +
			geom_point()+ 
			scale_color_manual(values=c('grey80','red')) +
			scale_size_manual(values = c(2, 4))+
			theme_classic()+ 
			theme(legend.position = "none")  +
			labs(title=paste("Condition ", cond, sep = ""), x="", y = "Minimum Z-score") +
			geom_hline(yintercept = (3.5), linetype="dashed", color = "blue") +ylim(c(0,25)) +
			geom_hline(yintercept = (10), linetype="dashed", color = "gold") 
	}

	myplot = grid.arrange(plots[[1]], plots[[2]], plots[[3]], plots[[4]], ncol=1,
		top = paste(virus, " (Dashed lines are Z =3.5 and 10, Public Epitopes in Red)", sep =""))
	print(myplot)
}
dev.off()


# Plotting the MEDIAN Z-score across the replicates for each peptide, and creating separate plots for each individual. (Simplified for grant submissions)
viral_plotfile =paste(mwd,"/Median_Z-score_plots_by_condition_max25_Simplified.pdf", sep = "")
pdf(viral_plotfile, width = 3, height=5, onefile = TRUE)
for(virus in my_viruses){
	print(virus)
	subdf = counts_sub[which(counts_sub$Species == virus),]
	subdf$index = c(1:nrow(subdf))
	plots = list()
	for(cond in c(1:4)){
		subdf$means= NA
		for(t in c(1:nrow(subdf))){
			subdf$means[t] = median(as.numeric(subdf[t, which(colnames(subdf) %in% conditions[[cond]])]))
		}

		subdf$means[which(subdf$means >20 )]= 20
		subdf$means[which(subdf$means <0 )]= 0

		plots[[cond]] = ggplot(subdf, aes(x=index, y=means, color=Public, size =Public)) +
			geom_point(alpha = 0.7)+ 
			scale_color_manual(values=c('grey50', 'grey50')) +
			scale_size_manual(values = c(1,1))+
			theme_classic()+ 
			theme(legend.position = "none",  axis.text.x = element_blank(),
				axis.text.y = element_blank(), axis.ticks = element_blank())  +
			labs(title="", x="", y = "") +
			geom_hline(yintercept = (3.5), linetype="dashed", color = "blue") +ylim(c(0,25)) +
			geom_hline(yintercept = (10), linetype="dashed", color = "gold") 

	}
	myplot = grid.arrange(plots[[1]], plots[[2]], plots[[3]], plots[[4]], ncol=1, top = paste(virus, sep =""))
	print(myplot)
}
dev.off()




