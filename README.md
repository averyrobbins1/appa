
# appa

<!-- badges: start -->
<!-- badges: end -->

The goal of appa is to provide an easy way to share Avatar: The Last Airbender
transcript data.

## Installation

You can install appa from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("averyrobbins1/appa")
```

## Example

This is a basic example which shows you how to solve a common problem:

```r
library(tidyverse)

dat <- appa::appa

glimpse(dat)

dat %>% 
    mutate(book = as_factor(book)) %>% 
    ggplot(aes(x = chapter_num, y = imdb_rating)) +
    geom_point() +
    facet_wrap(~ book)

```

