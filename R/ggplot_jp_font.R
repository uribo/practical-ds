ggplot_jp_font <-
  function (p,
            width = getOption("repr.plot.width"),
            height = getOption("repr.plot.height"),
            dpi = getOption("repr.plot.res")) {
    
    font_family = dplyr::if_else(grepl("mac", sessioninfo::os_name()),
                                 "IPAexGothic",
                                 "IPAGothic")
    
    if (is.null(getOption("repr.plot.width")))
      width = 7
    if (is.null(getOption("repr.plot.height")))
      height = 7
    if (is.null(getOption("repr.plot.res")))
      dpi = 120
    
    out_tmp_file <- tempfile(fileext = ".png")
    
    ggplot2::ggsave(filename = out_tmp_file,
                    device = "png",
                    plot = last_plot() +
                      theme_update(text = element_text(family = font_family)),
                    width = width,
                    height = height,
                    dpi = dpi)
    
    htmltools::img(src = base64enc::dataURI(file = out_tmp_file, mime = "imgage/png"), 
                   width = getOption("repr.plot.width") * 100, 
                   height = getOption("repr.plot.height") * 100)
  }
