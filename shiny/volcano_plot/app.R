
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

			# Horizontal line ----
			tags$hr(),

			sliderInput(inputId = "max_odds_ratio", 
				label = "Max Odds Ratio",
				value = 5, min = 1.25, max = 10, step = 0.25),

			sliderTextInput("pvalue","PValue:",
				choices=c(0.00001, 0.00005, 0.0001, 0.0005, 0.001, 0.005, 0.01),
				selected=0.00001, grid = T),

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

				rawdf <- rawdf %>% mutate(label = ifelse(pval <= input$pvalue, as.character(peptide), ""))

				df<-rawdf %>% mutate(sig=ifelse(pval < input$pvalue,"yes","no"))

			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)

		return( df )
	})

	output$plot <- renderPlot({
		req(input$file1)

		ggplot(df(), aes(x = exp_beta, y = -log10(pval),size=sig,fill=sig)) +
			ggtitle(input$file1$name) +
			geom_vline(xintercept=1, linewidth = 0.5,col="gray60",linetype=2)+
			coord_cartesian(xlim = c(1.9-input$max_odds_ratio, 0.1+input$max_odds_ratio)) +
			geom_point(aes(fill=sig,size=sig),shape=21) +
			geom_text(aes(label=as.character(label)), hjust=0.5, nudge_y = 0.1)+
			geom_hline(yintercept=1.305, linewidth = 0.5, linetype=2)+
			scale_fill_manual(values=c("#AAAAAA","#2ED0FE"),label=c(paste0(">",input$pvalue),paste0("<",input$pvalue)),name=c("p-value")) +
			scale_size_manual(values=c(2.5,4.5), label=c(paste0(">",input$pvalue),paste0("<",input$pvalue)),name=c("p-value")) +
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

