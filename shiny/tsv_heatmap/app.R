
library('shiny')
library('shinyWidgets')
library('pheatmap')
library('tidyr')
#library('dplyr')

options(shiny.maxRequestSize = 50*1024^2)

#library(shinyjs)

#cv <- sd(data) / mean(data) * 100

cv <- function(data){
    sd(data) / mean(data) * 100
}

# Define UI for data upload app ----
#	fluidPage is apparently 12 unit wide.
#	by default the sidebarPanel is then 4 units wide and the mainPanel is 8
ui <- fluidPage(
#useShinyjs(),

	# App title ----
	titlePanel("TSV Heatmap"),

	# Sidebar layout with input and output definitions ----
	sidebarLayout(

		# Sidebar panel for inputs ----
		sidebarPanel( width = 2,

			# Input: Select a file ----
			fileInput("file1", "Choose TSV File",
				multiple = FALSE,
				accept = c(".gz", 
					"text/tsv", "text/tab-separated-values,text/plain", ".tsv",
					"text/csv", "text/comma-separated-values,text/plain", ".csv")),

			# Input: Checkbox if file has header ----
			checkboxInput("header", "Header", TRUE),

			checkboxInput("cluster_rows", "Cluster Rows", TRUE),

			checkboxInput("cluster_cols", "Cluster Cols", TRUE),

			# Input: Select separator ----
			radioButtons("sep", "Separator",
				choices = c(Comma = ",",
				Semicolon = ";",
				Tab = "\t"),
				selected = "\t"),

			selectInput('scale', 'pHeatmap Scale', c('none','row','column')),

#			apply(df, 1, function(x) ( max(x) > minimum ) && ( min(x) < maximum ) ),
#			apply(df, 2, function(x) ( max(x) > minimum ) && ( min(x) < maximum ) ) ]

#			textInput("maximum","Maximum (minimum of a row or column must be less than)"),
#			textInput("minimum","Minimum (maximum of a row or column must be more than)"),

			hr(),
			p("Filters Rows/Columns:"),

			textInput("max_median","Maximum Median"),
			textInput("min_median","Minimum Median"),

			textInput("max_sd","Maximum Stddev"),
			textInput("min_sd","Minimum Stddev"),

			textInput("max_var","Maximum Variance"),
			textInput("min_var","Minimum Variance"),

			textInput("max_cv","Maximum CV"),
			textInput("min_cv","Minimum CV"),

			#uiOutput("slider_maximum"),
			#uiOutput("slider_minimum"),
			#verbatimTextOutput("breaks")

		),	#	sidebarPanel( width = 2,


		# Main panel for displaying outputs ----
		mainPanel(

			# Output: Tabset w/ plot, summary, and table ----
			tabsetPanel(type = "tabs",
				tabPanel("Plot", plotOutput(outputId = "plot",height="1000px")),
				tabPanel("Table", tableOutput("table"))
			)

		)	#	mainPanel(
	)	#	sidebarLayout(
)	#	ui <- fluidPage(



# Define server logic to read selected file ----
server <- function(input, output, session) {

	df <- reactive({

		# input$file1 will be NULL initially. After the user selects
		# and uploads a file, 

		req(input$file1)

		tryCatch(
			{
				df <- read.csv( input$file1$datapath,
					na.strings = c("", "-"),
					header = input$header, 
					sep = input$sep
				)
			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)


		row.names(df)=df[[colnames(df)[1]]]
		df[[colnames(df)[1]]]=NULL

		print("BEGIN replacing NAs")
		df[is.na(df)] <- 0
		print("DONE replacing NAs")

		#	The following is to detect when the file changes

		if(is.null(session$userData$filedatapath)){
			filedatapath=""
		}else{
			filedatapath=session$userData$filedatapath
		}

		#	https://shiny.posit.co/r/reference/shiny/0.14/updatetextinput
		print("BEGIN Scoring")
		updateTextInput(session, "max_median", label = paste0("Maximum Median (",max(apply(df, 1, median)),")"))
		updateTextInput(session, "min_median", label = paste0("Minimum Median (",min(apply(df, 1, median)),")"))

		updateTextInput(session, "max_sd", label = paste0("Maximum Stddev (",max(apply(df, 1, sd)),")"))
		updateTextInput(session, "min_sd", label = paste0("Minimum Stddev (",min(apply(df, 1, sd)),")"))

		updateTextInput(session, "max_var", label = paste0("Maximum Variance (",max(apply(df, 1, var)),")"))
		updateTextInput(session, "min_var", label = paste0("Minimum Variance (",min(apply(df, 1, var)),")"))

		updateTextInput(session, "max_cv", label = paste0("Maximum CV (",max(apply(df, 1, cv)),")"))
		updateTextInput(session, "min_cv", label = paste0("Minimum CV (",min(apply(df, 1, cv)),")"))
		print("DONE Scoring")


#		if( input$file1$datapath != filedatapath ){
#			session$userData$filedatapath=input$file1$datapath
#			output$slider_maximum <- renderUI({
#				sliderInput(
#					inputId = "maximum",
#					label = "Maximum:",
#					min   = floor(min(df)),
#					max   = ceiling(max(df)),
#					step  = 10,
#					value = max(df)
#				)
#			})
#			output$slider_minimum <- renderUI({
#				sliderInput(
#					inputId = "minimum",
#					label = "Minimum:",
#					min   = floor(min(df)),
#					max   = ceiling(max(df)),
#					step  = 10,
#					value = min(df)
#				) #			})
#		}

		return( df )
	})

	filter_df <- function(df){
		max_median <- if(is.null(input$max_median) || input$max_median=="" ) 
			max(apply(df,1,median,na.rm=TRUE)) else as.double(input$max_median)
		min_median <- if(is.null(input$min_median) || input$min_median=="" ) 
			min(apply(df,1,median,na.rm=TRUE)) else as.double(input$min_median)
		df = df[
			apply(df, 1, function(x) ( median(x,na.rm=TRUE) >= min_median ) && ( median(x,na.rm=TRUE) <= max_median ) ),
			apply(df, 2, function(x) ( median(x,na.rm=TRUE) >= min_median ) && ( median(x,na.rm=TRUE) <= max_median ) ) ]

		max_var <- if(is.null(input$max_var) || input$max_var=="" ) max(apply(df, 1, var)) else as.double(input$max_var)
		min_var <- if(is.null(input$min_var) || input$min_var=="" ) min(apply(df, 1, var)) else as.double(input$min_var)
		df = df[ 
			apply(df, 1, function(x) ( var(x) <= max_var ) && ( var(x) >= min_var ) ),
			apply(df, 2, function(x) ( var(x) <= max_var ) && ( var(x) >= min_var ) ) ]

		max_sd <- if(is.null(input$max_sd) || input$max_sd=="" ) max(apply(df, 1, sd)) else as.double(input$max_sd)
		min_sd <- if(is.null(input$min_sd) || input$min_sd=="" ) min(apply(df, 1, sd)) else as.double(input$min_sd)
		df = df[ 
			apply(df, 1, function(x) ( sd(x) <= max_sd ) && ( sd(x) >= min_sd ) ),
			apply(df, 2, function(x) ( sd(x) <= max_sd ) && ( sd(x) >= min_sd ) ) ]

		max_cv <- if(is.null(input$max_cv) || input$max_cv=="" ) max(apply(df, 1, cv)) else as.double(input$max_cv)
		min_cv <- if(is.null(input$min_cv) || input$min_cv=="" ) min(apply(df, 1, cv)) else as.double(input$min_cv)
		df = df[ 
			apply(df, 1, function(x) ( cv(x) <= max_cv ) && ( cv(x) >= min_cv ) ),
			apply(df, 2, function(x) ( cv(x) <= max_cv ) && ( cv(x) >= min_cv ) ) ]
	}

	output$plot <- renderPlot({
		req(input$file1)

		pheatmap(filter_df(df()),
			main=input$file1$name,
			fontsize=16,
			fontsize_row=10,
			fontsize_col=10,
			scale=input$scale,
			cluster_rows=input$cluster_rows, 
			cluster_cols=input$cluster_cols
		)

	})	#	output$plot <- renderPlot({

	output$table <- renderTable({
		req(input$file1)
		filter_df(df())
	}, rownames = TRUE)	#	output$table <- renderTable({

}	#	server <- function(input, output) {

# Create Shiny app ----
shinyApp(ui, server)


#	Setup
#install.packages('rsconnect')
#rsconnect::setAccountInfo(name='jakewendt',
#	token='<TOKEN>',
#	secret='<SECRET>')

#	Publish
#library(rsconnect)
#rsconnect::deployApp(".",account="jakewendt",appName="tsv_heatmap")

#	R -e "library(rsconnect);rsconnect::deployApp('.',account='jakewendt',appName='tsv_heatmap',forceUpdate = TRUE)"

#	Run locally
#	R -e "library(shiny);runApp(launch.browser = TRUE)"

