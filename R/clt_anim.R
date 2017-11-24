#' Animating the Results of \code{clt()}
#' 
#' \code{clt_anim()} animates the output of \code{clt()}. This is an experimental function
#' and may not work in many cases. It creates ggplot histograms of the z-scores for 
#' each value of N, showing how N converges to a normal distribution as it increases.
#' 
#' NOTE: This function requires ImageMagick and uses the magick package.
#'
#' @param N The data frame to create a gif from.
#' @param ci The confidence interval you would like to evaluate at. Default is 1.96.
#' @param xlim A vector of the left and right x limits for the generated plots. For
#' certain distributions limits should be adjusted to more of the domain.
#' @param compile If TRUE, the function will compile into a gif then delete temp images,
#' if FALSE will output raw images to the working directory.
#' @param fps The number of frames per second for the gif.
#' @param filename The output name of the .gif file.
#' 
#' @import glue
#' @import ggplot2
#' @import magick
#' @import magrittr
#' @importFrom gtools mixedsort
#' 
#' @export
#' 

clt_anim <- function(data = NULL,
                     ci = 1.96,
                     xlim = c(-4, 4),
                     compile = FALSE,
                     fps = 4,
                     filename = "clt.gif") {
  for (i in colnames(data)){
    data[[i]][data[[i]] < xlim[1] || data[[i]] > xlim[2]] <- NA
    clt_anim.plot <- ggplot(data,
                            aes(x=data[[i]])) + 
      geom_histogram(aes(y = ..density..),
                     binwidth = .25,
                     na.rm = TRUE) +
      geom_vline(xintercept = c(-ci, ci),
                 color = "red",
                 linetype = "longdash") +
      scale_x_continuous(limits = xlim) +
      scale_y_continuous(limits = c(0, .8)) +
      theme_bw() +
      labs(x = "Z-Score",
           y = "Density",
           title = glue(
             "Histogram of Z-Scores from {B} Distributions",
             B = nrow(data))) +
      annotate("label",
               x = (xlim[1] + 0.1),
               y = .77,
               hjust = 0,
               label = glue("N = {N}", N = i)) + 
      annotate("label",
               x = (xlim[1] + 0.1),
               y = .73,
               hjust = 0,
               label = glue("Rej. Rate = {a}",
                            a = sprintf("%0.3f", clt_eval(data[[i]])
                                        )
                            )
               )
    clt_anim.file = glue("N{i}.png", i = i)
    ggsave(filename = clt_anim.file,
           plot = clt_anim.plot,
           width = 6,
           height = 6)
  }
  message("Finished creating individual frames, saved in working directory")
  
  if (compile == TRUE) {
    message("Using ImageMagick to create gif file...")
    clt_anim.pngs <- image_read(mixedsort(list.files(pattern = "N*.png")))
    clt_anim.pngs <- image_scale(clt_anim.pngs, "600x600")
    clt_anim.gif <- image_animate(clt_anim.pngs, fps = fps, loop = 0)
    image_write(clt_anim.gif, path = filename)
    do.call(file.remove, list(list.files(pattern = "N*.png")))
    message("Finished creating gif, saved in the working directory")
  }
}
