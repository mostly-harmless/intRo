transform_ui <- tabPanel("Transform",
                                                  column(4,
                                                         wellPanel(                                          
                                                             selectInput("trans", "Choose Transformation", choices = c("Power" = "power", "Categorical" = "categorical", "Numeric" = "numeric")),
                                                             selectInput("var_trans", "Select Variable", choices = numericNames(mpg)),
                                                             conditionalPanel(condition = "input.trans == 'power'",
                                                                              sliderInput("power", "Power", value = 1, min = -5, max = 5, step = 0.1)
                                                             ),
                                                             
                                                             hr(),
                                                             
                                                             tags$button("", id = "savetrans", type = "button", class = "btn action-button", list(icon("save"), "Save Transformation"), onclick = "$('#side-nav :contains(\"Sources\")').highlight();")
                                                         )
                                                  ),
                                                  
                                                  column(8,
                                                         textOutput("var_trans_text"),
                                                         
                                                         hr(),
                                                         
                                                         conditionalPanel(condition = "input.trans == 'power'",
                                                                          tags$b("Original Data"),
                                                                          ggvisOutput("var_plot")
                                                         ),
                                                         
                                                         hr(),
                                                         
                                                         conditionalPanel(condition = "input.trans == 'power'",
                                                                          tags$b("Transformed Data"),
                                                                          ggvisOutput("trans_plot")
                                                         )
                                                  )
                                         )