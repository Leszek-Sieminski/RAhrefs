# RAhrefs
R package for SEO specialists which serves as an interface for [Ahrefs](ahrefs.com) API. 

## Features
* Authenticate with an API key 
* Download data from 24 Ahrefs reports as formatted data frames
* Use ordering with "order_by" parameter
* Create your own selecting conditions with "where and "having" clauses (experimental)

## Acquiring API access token
Visit your [Ahrefs API profile](https://ahrefs.com/api/profile) and copy your API access token.

## Installation

```r
install.packages("devtools")
devtools::install_github("Leszek-Sieminski/RAhrefs")
```

## Authentication
```r
library("RAhrefs")
api_key <- "012345"
RAhrefs::rah_auth(api_key)
# will return "API authorized" if success
```

## Creating conditions (experimental)
```r
# first, create all needed conditions in single form:
cond_1 <- RAhrefs::rah_condition(
  column_name = "first_seen",
  operator = "GREATER_THAN",
  value = "2018-01-01",
  is_date = TRUE)

cond_2 <- RAhrefs::rah_condition(
  column_name = "backlinks",
  operator = "GREATER_THAN",
  value = "10")

# next, create a set of conditions from them:
final_condition_set <- RAhrefs::rah_condition_set(cond_1, cond_2)

# finally, use the set of conditions to download choosen results:
result <- RAhrefs::rah_anchors(
  target = "ahrefs.com", 
  limit = 1000, 
  where = final_condition_set)
```
## Usage
```r
ahrefs_data <- RAhrefs::rah_anchors(
  target = "ahrefs.com",
  mode = "domain",
  limit = 2,
  where   = RAhrefs::rah_condition_set(
    RAhrefs::rah_condition(
      column_name = "backlinks",
      operator = "GREATER_THAN",
      value = "10"),
    RAhrefs::rah_condition(
      column_name = "refpages",
      operator = "GREATER_THAN",
      value = "20")),
  order_by = "refpages:asc")
  
print(ahrefs_data)
# >      anchor backlinks refpages refdomains          first_seen        last_visited
# > 1.21 driver        42       21          1 2018-06-06 07:16:28 2019-01-05 10:37:13
# >    a href's        21       21          1 2015-11-22 14:30:18 2015-11-22 14:30:18

str(ahrefs_data)
# > 'data.frame':	2 obs. of  6 variables:
# >  $ anchor      : chr  "1.21 driver" "a href's"
# >  $ backlinks   : int  42 21
# >  $ refpages    : int  21 21
# >  $ refdomains  : int  1 1
# >  $ first_seen  : POSIXct, format: "2018-06-06 07:16:28" "2015-11-22 14:30:18"
# >  $ last_visited: POSIXct, format: "2019-01-05 10:37:13" "2015-11-22 14:30:18"
```
