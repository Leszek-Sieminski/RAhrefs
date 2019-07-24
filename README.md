# RAhrefs 0.1.4
![Lifecycle_Status](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)
[![Build Status](https://travis-ci.org/Leszek-Sieminski/RAhrefs.svg?branch=master)](https://travis-ci.org/Leszek-Sieminski/RAhrefs)
[![Build status](https://ci.appveyor.com/api/projects/status/5502p5f854fv5dtc?svg=true)](https://ci.appveyor.com/project/Leszek-Sieminski/rahrefs)
[![codecov](https://codecov.io/gh/Leszek-Sieminski/RAhrefs/branch/master/graph/badge.svg)](https://codecov.io/gh/Leszek-Sieminski/RAhrefs)
[![CRAN status](https://www.r-pkg.org/badges/version/RAhrefs)](https://CRAN.R-project.org/package=RAhrefs)


R package for SEO specialists which serves as an interface for [Ahrefs](https://ahrefs.com/) API. 

* [What is Ahrefs?](#what-is-ahrefs)
* [News](#news)
* [Features](#features)
* [Acquiring API access token](#acquiring-api-access-token)
* [Testing](#testing)
* [Installation](#installation)
* [Authentication](#authentication)
* [Checking available reports](#checking-available-reports)
* [Checking available metrics](#checking-available-metrics)
* [Creating conditions](#creating-conditions)
* [Usage](#usage)
* [Other Ahrefs API packages](#other-ahrefs-api-packages)


## What is Ahrefs?
Ahrefs is a research toolset for backlinks and SEO analysis that enables access to off-site data.

## News
For more, see the [NEWS.md](https://github.com/Leszek-Sieminski/RAhrefs/blob/master/NEWS.md)
* 0.1.4 - fixing condition creating function - there was an error with regex-like operators
* 0.1.3 - fixing wrong assertthat usage in helper function

## Features
* Authenticate with an API key 
* Download data from 24 Ahrefs reports as formatted data frames
* Use ordering with "order_by" parameter
* Create your own selecting conditions with "where and "having" clauses (experimental)

## Acquiring API access token
Visit your [Ahrefs API profile](https://ahrefs.com/api/profile) and copy your API access token.

## Testing
IMPORTANT NOTE: for testing purposes, target "ahrefs.com" domain - no API credits will be used.

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

## Checking available reports
To check what Ahrefs data are available in R through API, you need to check provided help dataset:
```r
library("RAhrefs")
View(ahrefs_reports) # view dataset in a new tab (RStudio)
print(head(ahrefs_reports, 5)) # see first 5 reports in the console

# >         report_name          function_name                                                                                   short_description                                             url_address
# > 1        ahrefs_rank        rah_ahrefs_rank                                                                 Contains the URLs and the rankings.        https://ahrefs.com/api/documentation/ahrefs-rank
# > 2            anchors            rah_anchors Contains the anchor text and the num of backlinks, referring pages and referring domains that has it.            https://ahrefs.com/api/documentation/anchors
# > 3 anchors_refdomains rah_anchors_refdomains                               Contains the num of anchors and backlinks with that anchor, per domain. https://ahrefs.com/api/documentation/anchors-refdomains
# > 4          backlinks          rah_backlinks           Contains the backlinks and details of the referring pages, such as anchor and page title.          https://ahrefs.com/api/documentation/backlinks
# > 5 backlinks_new_lost rah_backlinks_new_lost                              Contains the new or lost backlinks and details of the referring pages. https://ahrefs.com/api/documentation/backlinks-new-lost
```

## Checking available metrics
To check what metrics can be choosen, you need to check provided help dataset:
```r
library("RAhrefs")
View(ahrefs_metrics) # view dataset in a new tab (RStudio)
print(head(ahrefs_metrics, 5)) # see first 5 metrics in the console

# >         metric   type use_where? use_having?                                  description
# > 1      url_from string       TRUE        TRUE URL of the page where the backlink is found.
# > 2        url_to string       TRUE        TRUE URL of the page the backlink is pointing to.
# > 3   ahrefs_rank    int       TRUE        TRUE            URL Rating of the referring page.
# > 4 domain_rating    int      FALSE        TRUE       Domain Rating of the referring domain.
# > 5    ahrefs_top    int      FALSE        TRUE            Ahrefs Rank of the target domain.
```
However, different functions can accept different metrics for experimental `where` & ` having` conditions. To find out which ones are available for a particular function, check that function's documentation.

## Creating conditions
Ahrefs API can use `where`, `having` and `order_by` parameters. However, behaviour of `where` and `having` may change in further updates.
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
# library ----------------------------
library("RAhrefs")

# authentication ---------------------
api_key <- "012345"
RAhrefs::rah_auth(api_key)

# downloading data -------------------
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

## Other Ahrefs API packages
* PHP - [ahrefs/ahrefs-api-php](https://github.com/ahrefs/ahrefs-api-php)
* R   - [mhairi/ahrefs](https://github.com/mhairi/ahrefs)
* Node JS - [ybonnefond/node-ahrefs](https://github.com/ybonnefond/node-ahrefs)
* Python - [spremotely/ahrefs-api-python](https://github.com/spremotely/ahrefs-api-python)
