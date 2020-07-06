#' Avatar: The Last Airbender data
#'
#' A dataset containing the transcripts, writers, directors, and imdb ratings
#' of the greatest animated tv show of all time - Avatar: The Last Airbender.
#'
#' @format A data frame with 13,385 rows and 12 variables:
#' \describe{
#'   \item{id}{an id number for each row, essentially just a row number}
#'   \item{book}{the name of each book, or season, in the series: Water,
#'   Earth, and Fire}
#'   \item{book_num}{an id number for each book, 1-3}
#'   \item{chapter}{the name of each chapter, or episode, in the series}
#'   \item{chapter_num}{an id number for each chapter}
#'   \item{character}{every character who ever spoke in the series}
#'   \item{full_text}{the words spoken by each character and some
#'   additional scene descriptions}
#'   \item{character_words}{the words spoken by each character}
#'   \item{scene_description}{the descriptions of what is happening on
#'   screen, often as the characters are talking}
#'   \item{writer}{the writer, or writers, for each episode}
#'   \item{director}{the director for each episode}
#'   \item{imdb_rating}{imdb ratings on a scale of 1 to 10}
#'
#' }
#' @source \url{https://avatar.fandom.com/wiki/Avatar:_The_Last_Airbender}
#'
#'  \url{https://www.imdb.com/list/ls079841896/}
"appa"
