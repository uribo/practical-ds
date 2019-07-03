step_stri_trans_new <- 
  function(terms, role, trained, converts, trans_id, skip, id) {
    recipes::step(
      subclass = "stri_trans", 
      terms = terms,
      role = role,
      trained = trained,
      converts = converts,
      trans_id = trans_id,
      skip = skip,
      id = id
    )
  }


step_stri_trans <- function(recipe, 
                            ..., 
                            role = "predictor", 
                            trained = FALSE,
                            converts = NULL,
                            trans_id = "nfkc",
                            skip = FALSE,
                            id = rand_id("stri_trans")) {
  
  terms <- recipes::ellipse_check(...)
  
  recipes::add_step(
    recipe, 
    step_stri_trans_new(
      terms = terms, 
      trained = trained,
      role = role, 
      converts = converts,
      trans_id = trans_id,
      skip = skip,
      id = id
    )
  )
}
prep.step_stri_trans <- function(x, training, info = NULL, ...) {
  col_names <- recipes::terms_select(terms = x$terms, info = info) 
  step_stri_trans_new(
    terms = x$terms, 
    trained = TRUE,
    role = x$role, 
    convert = col_names,
    trans_id= x$trans_id,
    skip = x$skip,
    id = x$id
  )
}

bake.step_stri_trans <- function(object, new_data, ...) {
  col_names <- object$converts
  for (i in col_names) {
    new_data[, i] <- apply(new_data[, i], 1, 
                           stringi::stri_trans_general, 
                           id = object$trans_id)
  }
  tibble::as_tibble(new_data)
}
