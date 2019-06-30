library(shiny)

debug <- FALSE
version <- "1.1"
date <- "2019 June 30"

#' Wavenumber from wave period
#' @param tau wave period [s]
#' @param H water depth [m]
#' @param g acceleration due to gravity [m/s^2]
#' @return wavenumber [1/m]
tau2k <- function(tau, H, g=9.8)
{
    omega <- function(k, H, g=9.8)
        sqrt(g * k * tanh(k * H))
    o <- 2 * pi / tau # omega [rad/s]
    n <- length(o)
    k <- rep(NA, n)
    for (i in seq_len(n)) {
        k[i] <- uniroot(function(K) o[i] - omega(K, H), 2*pi/c(1e3,1e-3))$root
    }
    k
}

#' Ratio of wave pressure signal at depth z to that just below the wave
#' @param k wavenumber [1/m]
#' @param z observation coordinate (converted to a negative number) [m]
#' @param H water depth [m]
#' @return Pressure-reduction factor.
reductionFactor <- function(k, z, H)
{
    H <- abs(H)
    z <- -abs(z)
    cosh(k*(z+H))/ cosh(k*H)
}

ui <- fluidPage(h5(paste("Wave pressure reduction through the water column (version ", version, ", ", date, ")", sep="")),
                fluidRow(column(12, radioButtons("instructions",
                                                 "",
                                                 choices=c("Hide Documentation", "Show Documentation"),
                                                 selected="Hide Documentation",
                                                 inline=TRUE))),
                fluidRow(conditionalPanel(condition="input.instructions=='Show Documentation'",
                                          withMathJax(includeMarkdown("wave_attenuation_help.md")))),
                fluidRow(column(6, sliderInput(inputId="H",
                                               label="Water depth [m]",
                                               min=1, max=100, value=20)),
                         column(6, sliderInput(inputId="hab",
                                               label="Sensor height above bottom",
                                               min=0, max=100, value=0))),
                fluidRow(uiOutput(outputId="hover")),
                fluidRow(plotOutput("plot", hover="hover")))

server <- function(input, output, session) {

    observeEvent(input$H, {
                 updateSliderInput(session=session, inputId="hab", value=0, max=input$H)
                })

    output$hover <- renderText({
        tau <- input$hover$x
        H <- abs(input$H)
        z <- -H + input$hab
        k <- tau2k(tau, H)
        rf <- reductionFactor(k=k, z=z, H=H)
        paste(sprintf(" Period: %.1fs, Pressure Factor: %.2g, Wave Length: %.1fm",
                      tau, rf, 2 * pi / k))
    })

    output$plot <- renderPlot({
        tau <- seq(1, 12, length.out=500)
        H <- abs(input$H)
        z <- -H + input$hab
        par(mar=c(3.3, 3.3, 1, 3.3), mgp=c(2, 0.7, 0))
        k <- tau2k(tau, H)
        rf <- reductionFactor(k=k, z=z, H=H)
        if (debug) {
            cat(file=stderr(), "hab=", input$hab, ", H=", H, "; therefore z=", z, "\n")
            cat(file=stderr(), "    head(k)=", paste(head(k), collapse=" "), "\n")
            cat(file=stderr(), "    head(tau)=", paste(head(tau), collapse=" "), "\n")
            cat(file=stderr(), "    head(reductionFactor)=", paste(head(rf), collapse=" "), "\n")
        }
        plot(tau, rf, type="l", lwd=2,
             xlab="Period [s]", ylab="Pressure Factor",
             xaxs="i", ylim=c(0, 1), yaxs="i")
        ##mtext(sprintf("Solid: pressure factor; dashed: wave length", z+H), side=3, line=-1, adj=0)
        legend("topleft", horiz=TRUE, lty=c("solid", "dashed"), lwd=2,
               legend=c("Pressure Factor", "Wave Length"), bg="white")
        ##mtext(sprintf("Sensor %.1fm above bottom", z+H), side=3, line=0.25, adj=0)
        par(new=TRUE)
        plot(tau, 2*pi/k, axes=FALSE, xlab="", ylab="", type="l", lwd=2, xaxs="i", yaxs="i", lty="dashed",
             ylim=c(0, max(2*pi/k)))
        axis(4)
        mtext("Wave Length [m]", side=4, line=2)
    }, pointsize=16)
}

shinyApp(ui, server)

