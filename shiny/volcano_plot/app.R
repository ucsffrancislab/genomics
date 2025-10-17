
library('shiny')
library('shinyWidgets')
#library('pheatmap')
library('tidyr')
#library('plotly')
library('data.table')

library('conflicted')

# Loading relevant libraries
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")

library('tidyverse') # includes ggplot2, for data visualisation. dplyr, for data manipulation.
library('RColorBrewer') # for a colourful plot
library('ggrepel') # for nice annotations



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

			fileInput("file1", "Choose CSV/TSV File",
				multiple = FALSE,
				accept = c(".gz", 
					"text/tsv", "text/tab-separated-values,text/plain", ".tbl",
					"text/tsv", "text/tab-separated-values,text/plain", ".tsv",
					"text/csv", "text/comma-separated-values,text/plain", ".csv")),

			# Input: Select separator ----
			radioButtons("sep", "Separator",
				choices = c(Comma = ",",
				Semicolon = ";",
				Tab = "\t"),
				selected = ","),

			# Horizontal line ----
			tags$hr(),

			sliderInput("xlim_range", "X-Axis Range:",
				min = -10, max = 10, value = c(0, 10)),

			sliderInput("ylim_range", "Y-Axis Range:",
				min = 0, max = 10, value = c(0, 10)),

#			sliderInput(inputId = "max_odds_ratio", 
#				label = "Max Odds Ratio",
#				value = 5, min = 1.25, max = 10, step = 0.25),

			# Input: Checkbox if file has header ----
			checkboxInput("exp_beta", "Exponentiate Beta", TRUE),

			sliderTextInput("pvalue","PValue:",
				choices=c(0.00001, 0.00005, 0.0001, 0.0005, 0.001, 0.005, 0.01),
				selected=0.00001, grid = T),

			#	not real sure the selectize does
			selectInput(
				inputId = "labelcol",
				label = "Label Column:",
				choices = c('peptide'),
				selected = 'peptide', multiple = FALSE, selectize = FALSE),

			selectInput(
				inputId = "pvaluecol",
				label = "P-Value Column:",
				choices = c('pval'),
				selected = 'pval', multiple = FALSE, selectize = FALSE),

			selectInput(
				inputId = "betacol",
				label = "Beta Column:",
				choices = c('beta'),
				selected = 'beta', multiple = FALSE, selectize = FALSE),

			textInput(
				inputId = "filtercol",
				label = "Filter Column:",
				value = 'species'),
			textInput(
				inputId = "filterval",
				label = "Filter Value:",
				value = ''),

		), #	sidebarPanel( width = 2,


		# Main panel for displaying outputs ----
		mainPanel(
			# Output: Tabset w/ plot, summary, and table ----
			tabsetPanel(type = "tabs",
				tabPanel("Table", tableOutput("table")),
				tabPanel("Plot", plotOutput(outputId = "plot",height="800px"))
				#tabPanel("Plot", plotlyOutput(outputId = "plot",height="800px"))
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
				rawdf <- data.frame(data.table::fread(input$file1$datapath, sep = input$sep, header=TRUE))
			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)

		updateSelectInput(session, "labelcol",
			choices = c(names(rawdf)),
			selected = 'peptide'
		)

		updateSelectInput(session, "pvaluecol",
			choices = c(names(rawdf)),
			selected = 'pval'
		)

		updateSelectInput(session, "betacol",
			choices = c(names(rawdf)),
			selected = 'beta'
		)

		return( rawdf )
	})

	filtered_df <- reactive({

		req(input$file1)

		tryCatch(
			{
				df = df()

				df <- df %>% drop_na()

				df <- df[df[,input$pvaluecol] < 0.9,]	#	remove those that log transform to near 0. this way should be able to remove hard limits

				df$my_selected_pvalue = df[,input$pvaluecol]

				df$my_selected_beta=df[,input$betacol]
				if( input$exp_beta ) { #== 'TRUE' ) {
					df$my_selected_beta=exp(df$my_selected_beta)
				}

				if( nzchar(input$filtercol) && nzchar(input$filterval) ){
					df <- df[df[,input$filtercol] == trimws(input$filterval),]
				}

				df <- df %>% mutate(my_selected_label = ifelse( df[,input$pvaluecol] <= input$pvalue, as.character(df[,input$labelcol]), ""))

				df <- df %>% mutate(sig=ifelse( df[,input$pvaluecol] < input$pvalue,"yes","no"))

			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}

		)

		minb = floor(min(df$my_selected_beta, na.rm=T))
		maxb = ceiling(max(df$my_selected_beta, na.rm=T))
		updateSliderInput(session, "xlim_range",
			min = minb, max = maxb, value = c(minb, maxb)
		)

		minp = floor(min(-log10(df$my_selected_pvalue), na.rm=T))
		maxp = ceiling(max(-log10(df$my_selected_pvalue), na.rm=T))
		updateSliderInput(session, "ylim_range",
			min = minp, max = maxp, value = c(minp, maxp)
		)

		return( df )
	})


	output$table <- renderTable({
		req(input$file1)
		#head(df(),50)
		head(filtered_df(),50)
	}, rownames = TRUE, digits=9 )


	output$plot <- renderPlot({
	#output$plot <- renderPlotly({
		req(input$file1)
#		req(input$pvaluecol)

		df=filtered_df()

		#p <- ggplot(df, aes(x = exp_beta, y = -log10(my_selected_pvalue),size=sig,fill=sig)) +
		p <- ggplot(df, aes(x = my_selected_beta, y = -log10(my_selected_pvalue),size=sig,fill=sig)) +
			ggtitle(input$file1$name) +
			geom_point(aes(fill=sig,size=sig),shape=21) +
			geom_text(aes(label=as.character(my_selected_label)), hjust=0.5, nudge_y = 0.1)+
			geom_hline(yintercept=1.305, linewidth = 0.5, linetype=2)+
			scale_fill_manual(values=c("#AAAAAA","#2ED0FE"),label=c(paste0(">",input$pvalue),paste0("<",input$pvalue)),name=c("p-value")) +
			scale_size_manual(values=c(2.5,4.5), label=c(paste0(">",input$pvalue),paste0("<",input$pvalue)),name=c("p-value")) +
			labs(x=input$betacol, y=expression(paste("-log"[10]*"(",italic("P"),")")))+
			theme_bw() +
			theme(panel.grid.minor = element_blank(),
				plot.title = element_text(size = 24, face = "bold"),
				legend.title = element_text(size=14, color="black",lineheight = 1),
				legend.text = element_text(size=13, color="black",lineheight = 1.2),
				axis.text=element_text(size=15,color="black",margin=margin(7,7,7,7,"pt")),
				axis.title = element_text(size=16,color="black",margin=margin(7,7,7,7,"pt")))

		if( input$exp_beta ) {
			p <- p + geom_vline(xintercept=1, linewidth = 0.5,col="gray60",linetype=2)
		} else {
			p <- p + geom_vline(xintercept=0, linewidth = 0.5,col="gray60",linetype=2)
		}

		p <- p + coord_cartesian()
		p <- p + xlim(input$xlim_range[1], input$xlim_range[2]) # Set x-axis limits based on slider input
		p <- p + ylim(input$ylim_range[1], input$ylim_range[2]) # Set y-axis limits based on slider input

		p

	})

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

