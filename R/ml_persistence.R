#' Spark ML -- Model Persistence
#'
#' Save/load Spark ML objects
#'
#' @param x A ML object, which could be a \code{ml_pipeline_stage} or a \code{ml_model}
#' @param path The path where the object is to be serialized/deserialized.
#' @param overwrite Whether to overwrite the existing path, defaults to \code{FALSE}.
#' @param sc A Spark connection.
#' @template roxlate-ml-dots
#'
#' @return \code{ml_save()} serializes a Spark object into a format that can be read back into \code{sparklyr} or by the Scala or PySpark APIs. When called on \code{ml_model} objects, i.e. those that were created via the \code{tbl_spark - formula} signature, the associated pipeline model is serialized. In other words, the saved model contains both the data processing (\code{RFormulaModel}) stage and the machine learning stage.
#'
#' \code{ml_load()} reads a saved Spark object into \code{sparklyr}. It calls the correct Scala \code{load} method based on parsing the saved metadata. Note that a \code{PipelineModel} object saved from a sparklyr \code{ml_model} via \code{ml_save()} will be read back in as an \code{ml_pipeline_model}, rather than the \code{ml_model} object.
#'
#' @name ml-persistence
NULL

#' @rdname ml-persistence
#' @export
ml_save <- function(x, path, overwrite = FALSE, ...) {
  UseMethod("ml_save")
}

#' @export
ml_save.default <- function(x, path, overwrite = FALSE, ...) {
  path <- ensure_scalar_character(path) %>%
    spark_normalize_path()
  overwrite <- ensure_scalar_boolean(overwrite)

  ml_writer <- spark_jobj(x) %>%
    invoke("write")

  if (overwrite) {
    ml_writer %>%
      invoke("overwrite") %>%
      invoke("save", path)
  } else {
    ml_writer %>%
      invoke("save", path)
  }
}

#' @rdname ml-persistence
#' @param type Whether to save the pipeline model or the pipeline.
#' @export
ml_save.ml_model <- function(x, path, overwrite = FALSE,
                             type = c("pipeline_model", "pipeline"), ...) {
  version <- x %>%
    spark_jobj() %>%
    spark_connection() %>%
    spark_version()

  # https://issues.apache.org/jira/browse/SPARK-11891
  if (version < "2.0.0")
    stop("Saving of 'ml_model' is supported in Spark 2.0.0+")

  path <- ensure_scalar_character(path) %>%
    spark_normalize_path()
  overwrite <- ensure_scalar_boolean(overwrite)
  type <- match.arg(type)

  ml_writer <- (
    if (identical(type, "pipeline_model")) x$pipeline_model else x$pipeline
    ) %>%
    spark_jobj() %>%
    invoke("write")

  if (overwrite) {
    ml_writer %>%
      invoke("overwrite") %>%
      invoke("save", path)
  } else {
    ml_writer %>%
      invoke("save", path)
  }
}

#' @rdname ml-persistence
#' @export
ml_load <- function(sc, path) {
  path <- ensure_scalar_character(path) %>%
    spark_normalize_path()

  class <- paste0(path, "/metadata/part-00000") %>%
    jsonlite::read_json() %>%
    `[[`("class")

  invoke_static(sc, class, "load", path) %>%
    ml_constructor_dispatch()
}
