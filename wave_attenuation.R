library(shiny)

debug <- FALSE

#' Wave celerity
#' @param k wavenumber [1/m]
#' @param H water depth [m]
#' @return celerity (wave phase speed) [m/s]
celerity <- function(k, H)
{
    g <- 9.8
    sqrt(g / k * tanh(k * H))
}

#' Wavenumber from wave period
#' @param tau wave period [s]
#' @param H water depth [m]
#' @return wavenumber [1/m]
tau2k <- function(tau, H)
{
    g <- 9.8
    ntau <- length(tau)
    k <- rep(NA, ntau)
    for (i in seq_len(ntau)) {
        k[i] <- uniroot(function(x) x-tau/celerity(tau[i], H), c(0,10))$root
    }
    k
}

tau2k <- function(tau, H)
    tau / celerity(tau, H)

#' Ratio of wave pressure signal at depth z to that just below the wave
#' @param k wavenumber [1/m]
#' @param z observation coordinate (converted to a negative number) [m]
#' @param H water depth [m]
reductionFactor <- function(k, z, H)
{
    H <- abs(H)
    z <- -abs(z)
    cosh(k*(z+H))/ cosh(k*H)
}

ui <- fluidPage(h5("Wave pressure reduction through the water column"),
                fluidRow(column(2, radioButtons("instructions",
                                                "Instructions",
                                                choices=c("Hide", "Show"),
                                                selected="Hide",
                                                inline=TRUE))),
                fluidRow(conditionalPanel(condition="input.instructions=='Show'",
                                          includeMarkdown("wave_attenuation_help.md"))),
                fluidRow(column(6, sliderInput(inputId="H",
                                               label="Water depth [m]",
                                               min=1, max=100, value=10, step=1)),
                         column(6, sliderInput(inputId="zOverH",
                                               label="Observation depth / water depth",
                                               min=0, max=1, value=0.1, step=0.01))),
                fluidRow(plotOutput("plot")))

server <- function(input, output) {
    output$plot <- renderPlot({
        tau <- seq(1, 12, length.out=500)
        H <- abs(input$H)
        z <- -input$zOverH * H
        par(mar=c(3, 3, 1, 1), mgp=c(2, 0.7, 0))
        k <- tau2k(tau, H)
        rf <- reductionFactor(k=k, z=z, H=H)
        if (debug) {
            cat(file=stderr(), "z=", z, "H=", H, "\n")
            cat(file=stderr(), "    head(k)=", paste(head(k), collapse=" "), "\n")
            cat(file=stderr(), "    head(tau)=", paste(head(tau), collapse=" "), "\n")
            cat(file=stderr(), "    head(reductionFactor)=", paste(head(rf), collapse=" "), "\n")
        }
        plot(tau, rf, type="l", lwd=2,
             xlab="Period [s]", ylab="Pressure reduction factor",
             xaxs="i", ylim=c(0, 1), yaxs="i")
        mtext(sprintf("Observation depth is %.1fm below the surface", -z), side=3, line=0, adj=1)
        grid()
    })
}

shinyApp(ui, server)

