
library('shiny')
library('shinyWidgets')
library('pheatmap')
library('tidyr')

options(shiny.maxRequestSize = 50*1024^2)

# Define UI for data upload app ----
#	fluidPage is apparently 12 unit wide.
#	by default the sidebarPanel is then 4 units wide and the mainPanel is 8
ui <- fluidPage(

	# App title ----
	titlePanel("Blast outfmt=6 sqrt(bitscore) Heatmap Viewer"),

	# Sidebar layout with input and output definitions ----
	sidebarLayout(

		# Sidebar panel for inputs ----
		sidebarPanel( width = 2,

			# Input: Select a file ----
			fileInput("file1", "Choose TSV File",
				multiple = FALSE,
				accept = c("text/tsv", "text/tab-separated-values,text/plain", ".tsv")),
				#accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv", ".tsv")),

			# Horizontal line ----
			tags$hr(),

			# Input: Checkbox if file has header ----
			checkboxInput("header", "Header", TRUE),

			# Horizontal line ----
			tags$hr(),

			sliderInput(inputId = "minpident", 
				label = "Minimum Percent Ident",
				value = 25, min = 0, max = 100, step = 1),

			sliderInput(inputId = "max_evalue_exponent", 
				label = "Maximum e-value EXPONENT",
				value = -1, min = -30, max = 1, step = 1),

			sliderInput(inputId = "minbitscore", 
				label = "Minimum bit score",
				value = 20, min = 0, max = 500, step = 1),

			selectInput('scale', 'pHeatmap Scale', c('none','row','column')),

			selectInput('variable', 'variable', c('bitscore','evalue')),

		), #	sidebarPanel( width = 2,


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
server <- function(input, output) {

	df <- reactive({

		req(input$file1)

		# when reading semicolon separated files,
		# having a comma separator causes `read.csv` to error
		tryCatch(
			{
				blast <- read.csv(input$file1$datapath,
					header = input$header, 
					sep = "\t")

				if( input$header == FALSE ){
					colnames(blast)=c(
						"qaccver","saccver","pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore")
				}

				#	column types can be a problem if has a header and box is unchecked

				blast = blast[ which( blast['evalue'] <= 10**input$max_evalue_exponent ), ]

				blast = blast[ which( blast['bitscore'] >= input$minbitscore ), ]

				blast = blast[ which( blast['pident'] >= input$minpident ), ]

				blast = blast[c('qaccver','saccver',input$variable)]


				df = blast %>% 
					pivot_wider( names_from = qaccver, values_from = input$variable, values_fn = max, values_fill = 0)

				df = as.data.frame(df)

				row.names(df)=df[[colnames(df)[1]]]

				df[[colnames(df)[1]]]=NULL

				#log_fun=function(x){ -log(x+1,base=10) }

				df1=data.frame(lapply(df,sqrt)) 

				row.names(df1)=row.names(df)

				#colnames(r1)=colnames(r)

			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)

		return( df1 )
	})

	output$plot <- renderPlot({
		req(input$file1)
		pheatmap(df(),
			main=input$file1$name,
			fontsize=16,
			fontsize_row=10,
			fontsize_col=10,
			scale=input$scale
		)
	})

	output$table <- renderTable({
		req(input$file1)
		head(df(),50)
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
#rsconnect::deployApp(".",account="jakewendt",appName="blast_heatmap")

#	Run locally
#	R -e "library(shiny);runApp(launch.browser = TRUE)"

