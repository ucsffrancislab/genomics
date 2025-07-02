
#	Shiny Apps

https://www.shinyapps.io/admin/

https://www.shinyapps.io/admin/#/tokens



https://jakewendt.shinyapps.io/tsv_heatmap/



if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(version = "3.20")

BiocManager::install(c( 'shiny', 'shinyWidgets', 'tidyr', 'data.table', 'conflicted', 'tidyverse', 'RColorBrewer', 'ggrepel'))


