% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ml_feature_quantile_discretizer_bucketizer.R
\name{ft_quantile_discretizer}
\alias{ft_quantile_discretizer}
\title{Feature Transformation -- QuantileDiscretizer (Estimator)}
\usage{
ft_quantile_discretizer(x, input_col, output_col, handle_invalid = "error",
  num_buckets = 2L, relative_error = 0.001, dataset = NULL,
  uid = random_string("quantile_discretizer_"), ...)
}
\arguments{
\item{x}{A \code{spark_connection}, \code{ml_pipeline}, or a \code{tbl_spark}.}

\item{input_col}{The name of the input column.}

\item{output_col}{The name of the output column.}

\item{handle_invalid}{(Spark 2.1.0+) Param for how to handle invalid entries. Options are
'skip' (filter out rows with invalid values), 'error' (throw an error), or
'keep' (keep invalid values in a special additional bucket). Default: "error"}

\item{num_buckets}{Number of buckets (quantiles, or categories) into which data
points are grouped. Must be greater than or equal to 2.}

\item{relative_error}{(Spark 2.0.0+) Relative error (see documentation for
org.apache.spark.sql.DataFrameStatFunctions.approxQuantile
\href{https://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrameStatFunctions}{here}
for description). Must be in the range [0, 1]. default: 0.001}

\item{dataset}{(Optional) A \code{tbl_spark}. If provided, eagerly fit the (estimator)
feature "transformer" against \code{dataset}. See details.}

\item{uid}{A character string used to uniquely identify the feature transformer.}

\item{...}{Optional arguments; currently unused.}
}
\value{
The object returned depends on the class of \code{x}.

\itemize{
  \item \code{spark_connection}: When \code{x} is a \code{spark_connection}, the function returns a \code{ml_transformer},
  a \code{ml_estimator}, or one of their subclasses. The object contains a pointer to
  a Spark \code{Transformer} or \code{Estimator} object and can be used to compose
  \code{Pipeline} objects.

  \item \code{ml_pipeline}: When \code{x} is a \code{ml_pipeline}, the function returns a \code{ml_pipeline} with
  the transformer or estimator appended to the pipeline.

  \item \code{tbl_spark}: When \code{x} is a \code{tbl_spark}, a transformer is constructed then
  immediately applied to the input \code{tbl_spark}, returning a \code{tbl_spark}
}
}
\description{
\code{ft_quantile_discretizer} takes a column with continuous features and outputs
  a column with binned categorical features. The number of bins can be
  set using the \code{num_buckets} parameter. It is possible that the number
  of buckets used will be smaller than this value, for example, if there
  are too few distinct values of the input to create enough distinct
  quantiles.
}
\details{
NaN handling: null and NaN values will be ignored from the column
  during \code{QuantileDiscretizer} fitting. This will produce a \code{Bucketizer}
  model for making predictions. During the transformation, \code{Bucketizer}
  will raise an error when it finds NaN values in the dataset, but the
  user can also choose to either keep or remove NaN values within the
  dataset by setting \code{handle_invalid} If the user chooses to keep NaN values,
  they will be handled specially and placed into their own bucket,
  for example, if 4 buckets are used, then non-NaN data will be put
  into buckets[0-3], but NaNs will be counted in a special bucket[4].

Algorithm: The bin ranges are chosen using an approximate algorithm (see
  the documentation for org.apache.spark.sql.DataFrameStatFunctions.approxQuantile
  \href{https://spark.apache.org/docs/latest/api/scala/index.html#org.apache.spark.sql.DataFrameStatFunctions}{here} for a detailed description). The precision of the approximation can be
  controlled with the \code{relative_error} parameter. The lower and upper bin
  bounds will be -Infinity and +Infinity, covering all real values.

Note that the result may be different every time you run it, since the sample
  strategy behind it is non-deterministic.

When \code{dataset} is provided for an estimator transformer, the function
  internally calls \code{ml_fit()} against \code{dataset}. Hence, the methods for
  \code{spark_connection} and \code{ml_pipeline} will then return a \code{ml_transformer}
  and a \code{ml_pipeline} with a \code{ml_transformer} appended, respectively. When
  \code{x} is a \code{tbl_spark}, the estimator will be fit against \code{dataset} before
  transforming \code{x}.

  When \code{dataset} is not specified, the constructor returns a \code{ml_estimator}, and,
  in the case where \code{x} is a \code{tbl_spark}, the estimator fits against \code{x} then
  to obtain a transformer, which is then immediately used to transform \code{x}.
}
\seealso{
See \url{http://spark.apache.org/docs/latest/ml-features.html} for
  more information on the set of transformations available for DataFrame
  columns in Spark.

\code{\link{ft_bucketizer}}

Other feature transformers: \code{\link{ft_binarizer}},
  \code{\link{ft_bucketizer}},
  \code{\link{ft_chisq_selector}},
  \code{\link{ft_count_vectorizer}}, \code{\link{ft_dct}},
  \code{\link{ft_elementwise_product}},
  \code{\link{ft_hashing_tf}}, \code{\link{ft_idf}},
  \code{\link{ft_imputer}},
  \code{\link{ft_index_to_string}},
  \code{\link{ft_interaction}}, \code{\link{ft_lsh}},
  \code{\link{ft_max_abs_scaler}},
  \code{\link{ft_min_max_scaler}}, \code{\link{ft_ngram}},
  \code{\link{ft_normalizer}},
  \code{\link{ft_one_hot_encoder}}, \code{\link{ft_pca}},
  \code{\link{ft_polynomial_expansion}},
  \code{\link{ft_r_formula}},
  \code{\link{ft_regex_tokenizer}},
  \code{\link{ft_sql_transformer}},
  \code{\link{ft_standard_scaler}},
  \code{\link{ft_stop_words_remover}},
  \code{\link{ft_string_indexer}},
  \code{\link{ft_tokenizer}},
  \code{\link{ft_vector_assembler}},
  \code{\link{ft_vector_slicer}}, \code{\link{ft_word2vec}}
}
