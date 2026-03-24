<div align="center">
  <h2>R Laboratory - Session 0</h2>
</div>

### Exercise 1 : Vectors and Data Frames

The following table (from [https://en.wikipedia.org/wiki/List_of_lochs_of_Scotland](https://en.wikipedia.org/wiki/List_of_lochs_of_Scotland)) reports the volume, area, length, and maximum and mean depth of several Scottish lakes:

| Loch | Volume<br>[km³] | Area<br>[km²] | Length<br>[km] | Max. depth<br>[m] | Mean depth<br>[m] |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Loch Ness | 7.45 | 56 | 39 | 230 | 132 |
| Loch Lomond | 2.6 | 71 | 36 | 190 | 37 |
| Loch Morar | 2.3 | 27 | 18.8 | 310 | 87 |
| Loch Tay | 1.6 | 26.4 | 23 | 150 | 60.6 |
| Loch Awe | 1.2 | 39 | 41 | 94 | 32 |
| Loch Maree | 1.09 | 28.6 | 20 | 114 | 38 |
| Loch Ericht | 1.08 | 18.6 | 23 | 156 | 57.6 |
| Loch Lochy | 1.07 | 16 | 16 | 162 | 70 |
| Loch Rannoch | 0.97 | 19 | 15.7 | 134 | 51 |
| Loch Shiel | 0.79 | 19.5 | 28 | 128 | 40 |
| Loch Katrine | 0.77 | 12.4 | 12.9 | 151 | 43.4 |
| Loch Arkaig | 0.75 | 16 | 19.3 | 109 | 46.5 |
| Loch Shin | 0.35 | 22.5 | 27.8 | 49 | 15.5 |

1. Create R vectors containing the lake names and the corresponding numerical variables. Build a data frame called `scottish.lakes`.

2. Determine :
   * the lake with the largest and the smallest volume,
   * the lake with the largest and the smallest surface area.

3. Order the data frame with respect to the lake area and determine the two lakes with the largest area.

4. By summing all the lake areas, compute the total area covered by these lakes.

### Exercise 2 : 100 m Athletics Records

The website [https://www.alltime-athletics.com/m_100ok.htm](https://www.alltime-athletics.com/m_100ok.htm) contains a list of the best recorded times in official men's 100 m races.

1. Open the results on the Web, reported as a table and create a `tibble` that contains all the results.

2. To parse the Web data, use the `rvest` and `tidyverse` packages and the following code :

```R
library(rvest)
library(tidyverse)
men100m_html <- read_html("http://www.alltime-athletics.com/m_100ok.htm")
men100m_html |> html_nodes(xpath = "//pre") |> html_text() -> men100m_list
men100m_tbl <- read_fwf(men100m_list)
```

3. The resulting `tibble` has all data represented as "character". Manipulate the `tibble` to convert the columns to the proper format.

4. Once `men100m_tbl` is properly formatted realize the following plots :
   (a) evolution of the fastest time as a function of date of the races
   (b) which country had the largest number of the fastest runners each year?

5. Repeat the same analysis for the women's 100 m races using [https://www.alltime-athletics.com/w_100ok.htm](https://www.alltime-athletics.com/w_100ok.htm) and compare the results between men and women.
