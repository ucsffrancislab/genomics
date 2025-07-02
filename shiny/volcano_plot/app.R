
library('shiny')
library('shinyWidgets')
#library('pheatmap')
library('tidyr')
library(data.table) 

library(conflicted)

# Loading relevant libraries
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")

library(tidyverse) # includes ggplot2, for data visualisation. dplyr, for data manipulation.
library(RColorBrewer) # for a colourful plot
library(ggrepel) # for nice annotations



options(shiny.maxRequestSize = 50*1024^2)

# Define UI for data upload app ----
#	fluidPage is apparently 12 unit wide.
#	by default the sidebarPanel is then 4 units wide and the mainPanel is 8
ui <- fluidPage(

	# App title ----
	titlePanel("Comparison Volcano Plot Viewer"),

	# Sidebar layout with input and output definitions ----
	sidebarLayout(

		# Sidebar panel for inputs ----
		sidebarPanel( width = 2,

			# Input: Select a file ----
#			fileInput("file1", "Choose TSV File",
#				multiple = FALSE,
#				accept = c("text/tsv", "text/tab-separated-values,text/plain", ".tsv")),
			fileInput("file1", "Choose CSV File",
				multiple = FALSE,
				accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
				#accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv", ".tsv")),

#			# Horizontal line ----
#			tags$hr(),
#
#			# Input: Checkbox if file has header ----
#			checkboxInput("header", "Header", TRUE),

			# Horizontal line ----
			tags$hr(),

			sliderInput(inputId = "max_odds_ratio", 
				label = "Max Odds Ratio",
				value = 5, min = 0, max = 10, step = 0.5),

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
				tabPanel("Plot", plotOutput(outputId = "plot",height="800px")),
				tabPanel("Table", tableOutput("table"))
			)
		)	#	mainPanel(
	)	#	sidebarLayout(
)	#	ui <- fluidPage(

# Define server logic to read selected file ----
server <- function(input, output, session) {

	df <- reactive({

		req(input$file1)

		# when reading semicolon separated files,
		# having a comma separator causes `read.csv` to error
		tryCatch(
			{
				rawdf <- data.frame(data.table::fread(input$file1$datapath, sep = ",", header=TRUE))

				rawdf = rawdf[rawdf$pval < 0.9,]	#	remove those that log transform to near 0. this way should be able to remove hard limits

				rawdf$exp_beta=exp(rawdf$beta)

	rawdf <- rawdf %>%
		mutate(label = ifelse(pval <=0.00005, as.character(peptide), ""))

				df<-rawdf %>% mutate(sig=ifelse(pval<0.00005,"yes","no"))




#				blast <- read.csv(input$file1$datapath,
#					header = input$header, 
#					sep = "\t")
#
#				if( input$header == FALSE ){
#					colnames(blast)=c(
#						"qaccver","saccver","pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore")
#				}
#
#				#	column types can be a problem if has a header and box is unchecked
#
#				blast = blast[ which( blast['evalue'] <= 10**input$max_evalue_exponent ), ]
#
#				blast = blast[ which( blast['bitscore'] >= input$minbitscore ), ]
#
#				blast = blast[ which( blast['pident'] >= input$minpident ), ]
#
#				blast = blast[c('qaccver','saccver',input$variable)]
#
#
#				df = blast %>% 
#					pivot_wider( names_from = qaccver, values_from = input$variable, values_fn = max, values_fill = 0)
#
#				df = as.data.frame(df)
#
#				row.names(df)=df[[colnames(df)[1]]]
#
#				df[[colnames(df)[1]]]=NULL
#
#				#log_fun=function(x){ -log(x+1,base=10) }
#
#				df1=data.frame(lapply(df,sqrt)) 
#
#				row.names(df1)=row.names(df)
#
#				#colnames(r1)=colnames(r)

			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)

#		return( df1 )
#		return( rawdf )
		return( df )
	})

	output$plot <- renderPlot({
		req(input$file1)
#		pheatmap(df(),
#			main=input$file1$name,
#			fontsize=16,
#			fontsize_row=10,
#			fontsize_col=10,
#			scale=input$scale
#		)

		#max_exp_beta=5	#max(df()$exp_beta, na.rm=T)



		ggplot(df(), aes(x = exp_beta, y = -log10(pval),size=sig,fill=sig)) +
			ggtitle(input$file1$name) +
			geom_vline(xintercept=1, linewidth = 0.5,col="gray60",linetype=2)+
			coord_cartesian(xlim = c(1.9-input$max_odds_ratio, 0.1+input$max_odds_ratio)) +
			geom_point(aes(fill=sig,size=sig),shape=21) +
		geom_text(aes(label=as.character(label)), hjust=0.5, nudge_y = 0.1)+
			geom_hline(yintercept=1.305, linewidth = 0.5, linetype=2)+
			scale_fill_manual(values=c("#AAAAAA","#2ED0FE"),label=c(">0.00005","<0.00005"),name=c("p-value")) +
			scale_size_manual(values=c(2.5,4.5), label=c(">0.00005","<0.00005"),name=c("p-value")) +
			labs(x="Odds Ratio", y=expression(paste("-log"[10]*"(",italic("P"),")")))+
			theme_bw() +
			theme(panel.grid.minor = element_blank(),
				plot.title = element_text(size = 24, face = "bold"),
				legend.title = element_text(size=14, color="black",lineheight = 1),
				legend.text = element_text(size=13, color="black",lineheight = 1.2),
				axis.text=element_text(size=15,color="black",margin=margin(7,7,7,7,"pt")),
				axis.title = element_text(size=16,color="black",margin=margin(7,7,7,7,"pt")))


	})

	output$table <- renderTable({
		req(input$file1)
		head(df(),50)
	}, rownames = TRUE, digits=9 )


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
#rsconnect::deployApp(".",account="jakewendt",appName="volcano_plot")

#	R -e "library(rsconnect);rsconnect::deployApp('.',account='jakewendt',appName='volcano_plot',forceUpdate = TRUE)"

#	Run locally
#	R -e "library(shiny);runApp(launch.browser = TRUE)"

