
library('shiny')
library('shinyWidgets')
#library('pheatmap')
#library('tidyr')


library('readr')
library('edgeR')
library('EDASeq')
library('ggplot2')
library('RColorBrewer')
library('pheatmap')
library('gridExtra')
library('grid') # New 20220712
library('gtable') # New 20220712
library('RColorBrewer')
library('biomaRt')
library('dplyr')
#library('DESeq2')	#	needed for plotPCA?
#library('BiocGenerics')	#	needed for plotPCA?
#library('ggfortify')	#	new for new plotPCA style?
library('kableExtra')
library('ggrepel')


#fruit = "apple"

#print("This is a test")


#		echo ${indir} ${outdir}/metadata.csv ${outdir} id ${column} NA NA ${i} 0.5 0.2 k${k} >> ${array_file}

# Column name in Covfile of the sample names 
#case_ID_col = 'id'
# Comma-separated list of covariates to adjust for, e.g. c("Age","sex","race")
covs = 'NA'
# Comma-separated list with the equal length to covs, indicating data types, e.g. c(numeric, factor, factor)
cov_types = 'NA'

	## Volcano Plots
	
	# make the volcano plot function here 
	Volcano_plot = function(glmt, label, alpha_thresh, logfc){
		glmt = data.frame(glmt$table)
		glmt$FDR=as.numeric(glmt$FDR)
		glmt$diffexpressed = "No"
		# if log2Foldchange > 0.6 and pvalue < 0.05, set as "UP" 
		glmt$diffexpressed[glmt$logFC > logfc & glmt$FDR < alpha_thresh] <- "Up"
		# if log2Foldchange < -0.6 and pvalue < 0.05, set as "DOWN"
		glmt$diffexpressed[glmt$logFC < -logfc & glmt$FDR < alpha_thresh] <- "Down"
	
		# Create a new column "delabel" to glmt, that will contain the name of genes differentially expressed (NA in case they are not)
		glmt$delabel <- NA
		glmt$delabel[glmt$diffexpressed != "No"] <- row.names(glmt[glmt$diffexpressed != "No",]) # CAREFUL HERE repname or rep family!!!!!
	
		glmt$PValue=as.numeric(glmt$PValue)
	
		# Re-plot but this time color the points with "diffexpressed"
		p <- ggplot(data=glmt, aes(x=logFC, y=-log10(PValue), col=diffexpressed, label=delabel)) + geom_point() + theme_minimal()+ geom_text_repel() + theme(title =element_text(size=8, face='bold'))
	
		# Add lines as before...
		p2 <- p + geom_vline(xintercept=c(-logfc, logfc), col="red") +
			geom_hline(yintercept=-log10(alpha_thresh), col="red")    
		# 1. by default, it is assigned to the categories in an alphabetical order):
		mycolors <- c("blue", "red", "black")
		names(mycolors) <- c("Down", "Up", "No")
		p3 <- p2 + scale_colour_manual(values = mycolors) + ggtitle(label)
	
		return(p3)
	
	}


options(shiny.maxRequestSize = 50*1024^2)

# Define UI for data upload app ----
#	fluidPage is apparently 12 unit wide.
#	by default the sidebarPanel is then 4 units wide and the mainPanel is 8
ui <- fluidPage(

	# App title ----
	titlePanel("REdiscoverTE EdgeR Viewer"),

	# Sidebar layout with input and output definitions ----
	sidebarLayout(

		# Sidebar panel for inputs ----
		sidebarPanel( width = 2,

			# Input: Select a file ----
			fileInput("file1", "Choose RDS File",
				multiple = FALSE,
				accept = c(".RDS")),

			# Horizontal line ----
			tags$hr(),

			# Input: Select a file ----
			fileInput("file2", "Choose metadata TSV File",
				multiple = FALSE,
				accept = c(".tsv")),

			# Horizontal line ----
			tags$hr(),

			textInput("case_ID_col", "case_ID_col", value = "case_submitter_id", width = NULL, placeholder = NULL),
			textInput("group_col", "group_col", value = "MGMT", width = NULL, placeholder = NULL),

			#textInput(alpha_thresh, alpha_thresh, value = "", width = NULL, placeholder = NULL),
			sliderInput(inputId = "alpha_thresh", 
				label = "alpha_thresh",
				value = 0.1, min = 0.01, max = 1.0, step = 0.01),

			#textInput(logFC_thresh, logFC_thresh, value = "", width = NULL, placeholder = NULL),
			sliderInput(inputId = "logFC_thresh", 
				label = "logFC_thresh",
				value = 0.1, min = 0.01, max = 1.0, step = 0.01),

#			# Input: Checkbox if file has header ----
#			checkboxInput("header", "Header", TRUE),
#
#			# Horizontal line ----
#			tags$hr(),
#
#			sliderInput(inputId = "minpident", 
#				label = "Minimum Percent Ident",
#				value = 25, min = 0, max = 100, step = 1),
#
#			sliderInput(inputId = "max_evalue_exponent", 
#				label = "Maximum e-value EXPONENT",
#				value = -1, min = -30, max = 1, step = 1),
#
#			sliderInput(inputId = "minbitscore", 
#				label = "Minimum bit score",
#				value = 20, min = 0, max = 500, step = 1),
#
#			selectInput('scale', 'pHeatmap Scale', c('none','row','column')),
#
#			selectInput('variable', 'variable', c('bitscore','evalue')),

		), #	sidebarPanel( width = 2,

		# Main panel for displaying outputs ----
		mainPanel(
			# Output: Tabset w/ plot, summary, and table ----
			tabsetPanel(type = "tabs",
				tabPanel("Summary", verbatimTextOutput("summary")),
				tabPanel("Heatmap", plotOutput(outputId = "heatmap")),
				tabPanel("BoxPlots", plotOutput(outputId = "boxplots")),
				tabPanel("PlotVolcanos", plotOutput(outputId = "plotvolcanos",height="800px")),
				tabPanel("PlotBCV", plotOutput(outputId = "plotbcv",height="800px")),
				tabPanel("PlotMDS", plotOutput(outputId = "plotmds",height="800px")),
				tabPanel("PlotPCA", plotOutput(outputId = "plotpca",height="800px")),
				tabPanel("RDS", tableOutput("RDS")),
				tabPanel("Metadata", tableOutput("Metadata"))
			)
		)	#	mainPanel(
	)	#	sidebarLayout(
)	#	ui <- fluidPage(



# Define server logic to read selected file ----
server <- function(input, output, session) {

	RDS <- reactive({
		req(input$file1)
		tryCatch( {
			tmp <- readRDS(input$file1$datapath)
		},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)
		return( tmp )
	})

	covars <- reactive({
		req(input$file2)
		tryCatch( {
#				blast <- read.csv(input$file1$datapath,
#					header = input$header, 
#					sep = "\t")
#			tmp = read_csv(input$file2$datapath, sep="\t", col_names = TRUE , col_types = cols(.default = "c") )
			tmp = read.csv(input$file2$datapath, sep="\t", header = TRUE, na.strings='' )
		},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)
		return( tmp )

	})



  # Generate a summary of the data ----
  output$summary <- renderPrint({
		req(input$file1, input$file2)
		RE_disc()
  })

	RE_disc <- reactive({

		req(input$file1, input$file2)

		message("Processing RE_disc")

		RE_disc <- RDS()

		#if( input$file1$name ~ "GENE" ){
		if( grepl( "GENE", input$file1$name, fixed = TRUE) ){

			um=useMart("ensembl")
			mart <- useDataset("hsapiens_gene_ensembl", um)

			ensembl_gene_id=rownames(RE_disc$counts)
			ensembl_gene_id=as.data.frame(ensembl_gene_id)
			conversion_table <- getBM(filters = "ensembl_gene_id",attributes = c("ensembl_gene_id","hgnc_symbol"),
				values = ensembl_gene_id$ensembl_gene_id, mart = mart, useCache = FALSE)

			joined=dplyr::left_join(ensembl_gene_id,conversion_table,by='ensembl_gene_id')

			joined = joined %>% group_by(ensembl_gene_id) %>% mutate(hgnc_symbol = paste(hgnc_symbol, collapse = ","))
			joined = as.data.frame(joined)
			joined = unique(joined)

			#	Some ensembl_gene_ids are not in the biomart. Set hgnc_symbol to ensembl_gene_id.
			joined$hgnc_symbol <- ifelse( joined$hgnc_symbol == "", joined$ensembl_gene_id, joined$hgnc_symbol )

			joined$hgnc_symbol <- ifelse( joined$hgnc_symbol == "NA", joined$ensembl_gene_id, joined$hgnc_symbol )

			rownames(joined)=joined$ensembl_gene_id
			joined=joined['hgnc_symbol']

			rownames(RE_disc$counts)=joined$hgnc_symbol
		}

		#Establish if there are covariates to include 
		#Cov_check = (is.na(covs) == FALSE)
		RE_disc$Cov_check = ((covs == "NA") == FALSE)
		
		if(RE_disc$Cov_check == FALSE){
			#	message("covs false")
			covs = c()
			cov_types = c()
		}

		# Add the group id to the REdiscover file  NO LONGER COMPATIBLE WITH SECONDARY GROUP
		group_list = data.frame(mat.or.vec(nrow(RE_disc$samples),(1+length(covs))))
		not.present= c()
		
		#covar_groups = covars[group_col]
		covar_groups = covars()[input$group_col]
		#	message("covar_groups")
		#	message(covar_groups)
		
		#return( covar_groups )
	
		#second_groups = covars[second_col]
		colnames(group_list)= c(input$group_col, covs)
		for(i in c(1:nrow(RE_disc$samples))){
		
			id = as.character(RE_disc$samples$sample[i])
			#	message("id")
			#	message(id)
			#print("group")
			#print(as.character(RE_disc$samples$group[i]))
		
			#id = data.set$id[i]
			#print(data.set$id[i])
			#print(id)
			#ref_id = which(covars[case_ID_col] == id)
			ref_id = which(covars()[input$case_ID_col] == id)
			#	message("ref_id")
			#	message(ref_id)
		
		
			#	Filter out samples that have been rolled up but not included in metadata file.
		
		
			if(length(ref_id)==1){
				#	message("length ref_id == 1")
				group_list[i,1] = as.character(covar_groups[ref_id,1])
				#group_list[i,2] = as.character(second_groups[ref_id,1])
				if(RE_disc$Cov_check ==TRUE){
					message(paste("length(covs) ",length(covs)))
					for(k in c(1:length(covs))){
						#group_list[i,(1+k)] = as.character(covars[covs[k]][ref_id,])
						group_list[i,(1+k)] = as.character(covars()[covs[k]][ref_id,])
					}
				}
			}else{
				#	message("length ref_id != 1")
				#	message(length(ref_id))
				#print(id)
				group_list[i,1]= "NA"
				#group_list[i,2]= "NA"
				if(RE_disc$Cov_check ==TRUE){
					for(k in c(1:length(covs))){
						group_list[i,(1+k)] = "NA"
					}
				}
				not.present= c(not.present,i)
			}
			#	message("group_list[i,1]")
			#	message(group_list[i,1])
		}	#	for(i in c(1:nrow(RE_disc$samples))){
		
		group_list[,1] = as.factor(group_list[,1])
		#group_list[,2] = as.factor(group_list[,2])
		if(RE_disc$Cov_check ==TRUE){
			for(k in c(1:length(covs))){
				group_list[,k+1]=as.character(group_list[,k+1])
			}
		}
	
	
		#	Remove the not present samples 
		
		if(length(not.present) >=1){
			message(paste("Number of samples not found in covariate file = ", length(not.present), sep = ""))
			#groups_less = group_list[-not.present,1]	#	????? Typo? Unused? Comment out?
			#second_less = group_list[-not.present,2]
			RE_disc= RE_disc[,-not.present]
			group_less =group_list[-not.present,]
		}else{
			message("group_list")
			message(group_list)
			group_less = group_list
		}
	
	
		# Cov_check is always FALSE, but if the metadata file contains other columns
		#	group_less needs to be group_less
		#	Otherwise group_less[,1] ????


		#	How to make sure that the ids in the metadata are the same as in the RDS file.


		message("class(group_less)")
		message(class(group_less))	#	data.frame
		group_less=group_less[,1]
		message(class(group_less))	#	factor


		
		if(RE_disc$Cov_check == TRUE){
			message("Cov_check == TRUE")
			RE_disc$samples$group = as.factor(group_less[,1])
		}else if( length(group_less) > 1 ){
			message("length(group_less) > 1")
			RE_disc$samples$group = as.factor(group_less)
		}else if( is.na(as.factor(group_less)) ){
			message("is.na(as.factor(group_less))")
			RE_disc$samples$group = as.factor(group_less[,1]) 
		}else{
			message("OTHER")
		
			message("group_less")
			message(group_less)
			message("length(group_less)")
			message(length(group_less))
		
			RE_disc$samples$group = as.factor(group_less)
		
		}

		if(RE_disc$Cov_check ==TRUE){
			for(k in c(1:length(covs))){
				RE_disc$samples[covs[k]] = type.convert(group_less[covs[k]], cov_types[k])
			}
		}


		# Filter out any groups with no group assignment (== NA)
		Nas = which(is.na(RE_disc$samples$group))
		if(length(Nas >0)){
			RE_disc=RE_disc[,-Nas]
		}

	
	

		# Filter out groups with too little sample size (i.e <10)
		u_groups = unique(RE_disc$samples$group)
		for(grp in u_groups){
			n_grp=which(RE_disc$samples$group == grp)
			n_in_group = length(n_grp)  
			if(n_in_group <1){
				RE_disc= RE_disc[,-n_grp]
			}
		}
		RE_disc$samples$group = droplevels(RE_disc$samples$group)
		
			
			
		
		# Filter out samples with NA covariates 
		if(RE_disc$Cov_check ==TRUE){
			for(cov_n in covs){
				Nas = which(is.na(RE_disc$samples[cov_n]))
				if(length(Nas >=1)){
					RE_disc = RE_disc[,-Nas]
				}
			}
		}
		
			
			
		# Analysis {.tabset .tabset-fade .tabset-pills}
			
		##	Prepare
		
		# ##### Filter out the Healthy individuals  REMOVE REMOVE REMOVE
		# healthy = which(RE_disc$samples$group =="Healthy")
		# RE_disc = RE_disc[,-healthy]
			
		# Make sure the "factor" covariates do not have levels with 0 entries
		if(RE_disc$Cov_check ==TRUE){
			for(k in c(1:length(covs))){
				if(cov_types[k]=="factor"){
					RE_disc$samples[covs[k]] = droplevels(RE_disc$samples[covs[k]])
				}
			}
		}
		summary(RE_disc$samples$group)
			
			
		#apply(x$counts, 2, sum)
		dim(RE_disc)
		RE_disc <- calcNormFactors(RE_disc, method = "RLE") # WAS RLE if this fails
			
		keep <- rowSums(cpm(RE_disc)>50) >= 2
		RE_disc <- RE_disc[keep,]
		dim(RE_disc)
		RE_disc$samples$lib.size <- colSums(RE_disc$counts)
		
			
		
		# Normalize the data
		RE_disc <- calcNormFactors(RE_disc, method = "RLE") # WAS RLE if this fails




		# Design Matrix -----------------------------------------------------------------------
		if(RE_disc$Cov_check ==TRUE){
			RE_disc$design.mat <- model.matrix(~ 0 +., RE_disc$samples[c("group",covs)]  )
		}else{
			RE_disc$design.mat <- model.matrix(~ 0 +., RE_disc$samples[c("group")]  )
		}


		#	Pre-compute for BCV2 and Volcano plots
		#colnames(RE_disc$design.mat) <- levels(RE_disc$samples$group)
		RE_disc$d2 <- estimateGLMCommonDisp(RE_disc,RE_disc$design.mat)
		RE_disc$d2 <- estimateGLMTrendedDisp(RE_disc$d2,RE_disc$design.mat, method="auto")
		# You can change method to "auto", "bin.spline", "power", "spline", "bin.loess".
		# The default is "auto" which chooses "bin.spline" when > 200 tags and "power" otherwise.
		RE_disc$d2 <- estimateGLMTagwiseDisp(RE_disc$d2,RE_disc$design.mat)


		#	Pre-compute for Volcano plots
		RE_disc$fit <- glmFit(RE_disc$d2, RE_disc$design.mat)



		
	

		return( RE_disc )

	})

			
	output$plotpca <- renderPlot({
		req(input$file1,input$file2)
		RE_disc=RE_disc()
		
		n_groups = length(unique(RE_disc$samples$group))
			
		# Get the proper group colors 
		u_groups = as.character(unique(RE_disc$samples$group))
		col_groups= brewer.pal(n = length(u_groups), name = "Set1")
		possible_shapes= c(21,22,23,24,25)
		shape_groups = c()
		for(i in c(1:length(u_groups))){
			shape_groups =c(shape_groups, possible_shapes[i%%length(possible_shapes)+1])
		}
			
		color_p = c()
		shape_p = c()
		for(i in c(1:length(RE_disc$samples$group))){
			color_p = c(color_p, col_groups[which(u_groups == RE_disc$samples$group[i])])
			shape_p = c(shape_p, shape_groups[which(u_groups == RE_disc$samples$group[i])])
		}

		#Normalization for PCA and t-SNE, not exactly the same 
		normcounts = 1e6*cpm(RE_disc, normalized.lib.sizes=T)

		#	## Perform PCA analysis and make plot
		#	plotPCA(normcounts, bg=color_p, labels= FALSE , pch=shape_p, col = "black",)
		#	plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
		#	legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
		plotPCA(normcounts, bg=color_p, labels= FALSE , pch=shape_p, col = "black", k=3)

	})

	output$plotmds <- renderPlot({
		req(input$file1,input$file2)
		RE_disc=RE_disc()

		n_groups = length(unique(RE_disc$samples$group))
			
		# Get the proper group colors 
		u_groups = as.character(unique(RE_disc$samples$group))
		col_groups= brewer.pal(n = length(u_groups), name = "Set1")
		possible_shapes= c(21,22,23,24,25)
		shape_groups = c()
		for(i in c(1:length(u_groups))){
			shape_groups =c(shape_groups, possible_shapes[i%%length(possible_shapes)+1])
		}
			
		color_p = c()
		shape_p = c()
		for(i in c(1:length(RE_disc$samples$group))){
			color_p = c(color_p, col_groups[which(u_groups == RE_disc$samples$group[i])])
			shape_p = c(shape_p, shape_groups[which(u_groups == RE_disc$samples$group[i])])
		}

		#Normalization for PCA and t-SNE, not exactly the same 
		#normcounts = 1e6*cpm(RE_disc, normalized.lib.sizes=T)

		#	"Dimension reduction via MDS is achieved by taking the original set of samples and calculating a dissimilarity (distance) measure for each pairwise comparison of samples. The samples are then usually represented graphically in two dimensions such that the distance between points on the plot approximates their multivariate dissimilarity as closely as possible."

		plotMDS(RE_disc, col = "black", pch = shape_p, bg= color_p)

		# this breaks stuff? and then only the legend is rendered
		#plot(NULL ,xaxt='n',yaxt='n',bty='n',ylab='',xlab='', xlim=0:1, ylim=0:1)
		legend("top", u_groups,  pch=shape_groups, col= "black", pt.bg=col_groups, y.intersp=1.25)
	})


	output$plotbcv <- renderPlot({
		req(input$file1,input$file2)
		RE_disc=RE_disc()

		#	layout of 2 rows, 1 column
		par(mfrow=c(2,1))
	
		# Dispersion analysis 
		d1 <- estimateCommonDisp(RE_disc, verbose=T)
		d1 <- estimateTagwiseDisp(d1)
		plotBCV(d1)

		plotBCV(RE_disc$d2)
	
	})



  output$plotvolcanos <- renderPlot({
		req(input$file1,input$file2)
		RE_disc=RE_disc()
	
		# make some contrast patterns
		col_groups = levels(RE_disc$samples$group)
		n_contrasts = choose(length(col_groups), 2)

		#Warning: Error in h: error in evaluating the argument 'x' in selecting a method for function 'ncol': object 'design.mat' not found

		contrasts = mat.or.vec(n_contrasts, ncol(RE_disc$design.mat))
		combos = t(combn(length(col_groups), 2))
		colnames(contrasts)= colnames(RE_disc$design.mat)
		for(nc in c(1:n_contrasts)){
			contrasts[nc,combos[nc,1]] =1
			contrasts[nc,combos[nc,2]] =-1
		}

		#	Only works for non-ggplots
		#par(mfrow=c(n_contrasts,1))

		# This section actually does all of the DE analysis, but prints out all of the volcano plots 
		sig_trans = c()
		results = list()
		plots=list()
		for(nc in c(1:n_contrasts)){

			message(paste0("In volcano for loop :",nc))

			lrt <- glmLRT(RE_disc$fit, contrast=contrasts[nc,])
			glmt = topTags(lrt, n=nrow(RE_disc))
			plots[[nc]] = Volcano_plot(glmt, as.character(glmt$comparison),as.numeric(input$alpha_thresh), as.numeric(input$logFC_thresh))
		
			pass_logFC= row.names(glmt$table[which(abs(glmt$table$logFC)>input$logFC_thresh),])
			pass_alpha = row.names(glmt$table[which(glmt$table$FDR<input$alpha_thresh),])
			pass_both = intersect(pass_logFC, pass_alpha)
			if(length(pass_both) > 0){
				sig_trans = c(sig_trans, pass_both)
			}

			glmt_res = glmt$table[which(row.names(glmt$table) %in% sig_trans),-which(colnames(glmt) == "LR")]
			if(nrow(glmt_res >0)){
				glmt_res$comparison = glmt$comparison
			}
			results[[nc]] = glmt_res
		}

		do.call("grid.arrange", c(plots, nrow=n_contrasts))

		RE_disc$sig_trans = sig_trans

	})



	
	#	All significant TEs are plotted here, the window is limited to a maximum value of 2 standard deviations above the mean expression. 
  output$boxplots <- renderPlot({
		req(input$file1,input$file2)
		RE_disc=RE_disc()
	
		#Normalization for PCA and t-SNE, not exactly the same 
		normcounts = 1e6*cpm(RE_disc, normalized.lib.sizes=T)

		# Plotting the top results for each pairwise test 
		to_plot = unique(RE_disc$sig_trans)
		message(paste0("to_plot: ",to_plot))
		
		for( gene in to_plot){
			message(gene)
			plot_data = data.frame(as.numeric(normcounts[which(row.names(normcounts) == gene),]))
			plot_data$group = RE_disc$samples$group
			#print(paste("Individual with max value = ", row.names(plot_data)[which(plot_data[,1] == max(plot_data[,1]))], sep=""))
			colnames(plot_data) = c(gene, "group")
			plot_data$group = as.factor(plot_data$group)
			# Plot limits based on mean and 2 sd above
			plot_max = mean(as.numeric(plot_data[,1])) + 2* sd(as.numeric(plot_data[,1]))
			excluded = length(which(as.numeric(plot_data[,1]) > plot_max))
			plot_max = min(max(as.numeric(plot_data[,1])), plot_max)
			message(paste(as.numeric(excluded), " samples are above the plot window and not pictured.", sep = ""))
			p <- ggplot(plot_data, aes(x=as.factor(plot_data[,2]), y=as.numeric(plot_data[,1]), fill=as.factor(plot_data[,2]))) +
			geom_boxplot()+
			labs(title=paste(gene, sep = ""),x=input$group_col, y = "Count (normalized)")+
			theme(legend.position= "right")+
			theme(plot.title = element_text(hjust = 0.5))+
			geom_jitter(color="black", size=0.2, alpha=0.1) +
			theme(axis.text.x = element_blank())+
			labs(fill = input$group_col) +
			theme(legend.key.size = unit(1, 'cm'), #change legend key size
			legend.key.height = unit(1, 'cm'), #change legend key height
			legend.key.width = unit(1, 'cm'), #change legend key width
			legend.title = element_text(size=7), #change legend title font size
			legend.text = element_text(size=5)) + ylim(0,plot_max)
		  
			print(p)
		}

		message("Done")

	})




#	## Significant Result Tables 
#	
#	for(nc in c(1:n_contrasts)){
#		kbltbl = (results[[nc]])[,-c(ncol(results[[nc]]))] %>%
#		kbl(caption = (results[[nc]])$comparison[1] ) %>%
#		kable_classic(full_width = F, html_font = "Cambria") %>%
#		scroll_box(width = "1000px", height = "300px")
#		print(kbltbl)
#	}






  output$heatmap <- renderPlot({
		req(input$file1,input$file2)
		RE_disc=RE_disc()
	
		to_plot = unique(RE_disc$sig_trans)
		message(paste0("to_plot: ",to_plot))

		#Normalization for PCA and t-SNE, not exactly the same 
		normcounts = 1e6*cpm(RE_disc, normalized.lib.sizes=T)

	sig.results = to_plot
	
	sig.loc = mat.or.vec(length(sig.results), 1)
	
	if(length(sig.loc) >1){
	
		for(i in c(1:length(sig.results))){
			sig.loc[i] = which(row.names(normcounts) == sig.results[i])
		}
		normcounts = normcounts[sig.loc,]
	
		gaps =c()
		# Need to reorder the data so that it is collected by group
		ordered= c()
		for(k in c(1:length(col_groups))){
			ordered = c(ordered,which(RE_disc$samples$group ==col_groups[k]) )
			if(k!=length(col_groups)){
				gaps=c(gaps,length(ordered))
			}
		}
		normcounts = normcounts[,as.integer(ordered)]
		Groups = RE_disc$samples$group
		names(Groups) = rownames(RE_disc$samples)
	
		colorpal= rev(brewer.pal(11,"RdBu"))
	
		pheat.plot=pheatmap(log(normcounts+0.01,base = 2), cluster_rows = T,scale="row", cluster_cols = F,annotation_col = data.frame(Groups),col=colorpal,show_colnames = FALSE ,gaps_col=gaps, main = paste(input$group_col, ": log_2 REdiscoverTE ", filetypes[filetype], sep ="") )
	#	print(pheat.plot)
		pheat.plot.clust = pheatmap(log(normcounts+0.01,base = 2), cluster_rows = T,scale="row", cluster_cols = T,annotation_col = data.frame(Groups),col=colorpal,show_colnames = FALSE ,gaps_col=gaps, main = paste(input$group_col, ": log_2 REdiscoverTE ", filetypes[filetype], " clustered", sep ="") )
	#	print(pheat.plot.clust)
	
	
	}else{
		print("Not enough significant results at these thresholds to plot a heatmap.")
	}


	})

	output$RDS <- renderTable({
		req(input$file1)
		#head(covars(),50)
		RDS()[1:10,1:10]
	}, rownames = TRUE)

	output$Metadata <- renderTable({
		req(input$file2)
		#head(covars(),50)
		covars()[1:10,]
	}, rownames = TRUE)

}

# Create Shiny app ----
shinyApp(ui, server)




#	Setup
#install.packages('rsconnect')
#rsconnect::setAccountInfo(name='jakewendt',
#	token='<TOKEN>',
#	secret='<SECRET>')

#	Publish
#library(rsconnect)
#rsconnect::deployApp(".",account="jakewendt",appName="REdiscoverTE_EdgeR")

#	R -e "library(rsconnect);rsconnect::deployApp('.',account='jakewendt',appName='REdiscoverTE_EdgeR',forceUpdate = TRUE)"

#	Run locally
#	R -e "library(shiny);runApp(launch.browser = TRUE)"



