/* 			WEEKLY SA BRIEF (COVID-19)
Company:	Fors Marsh Group
Purpose:	Visualize COVID-19 Data from NYTimes
Author:		Regina Chua, rchua@forsmarshgroup.com
Version:	5.0, 09/13/2020
Notes:		Automatic measure of beginning date. Simply run every
			Sunday before Monday distribution to get figures
			in the beginning week. */

*** SET ENVIRONMENT ---------------------------------

* Set options
vers 16
set graphics off
gr set window fontface "Helvetica"

* Set project path
loc path1	`" "C:/Users/`c(username)'/Fors Marsh Group LLC" "'
loc path2	`" "C:/Users/`c(username)'/Fors Marsh Group" "'

* Check paths and set directory
mata: st_numscalar("OK", direxists(`path1'))
	if (scalar(OK) == 1) 	gl dir `path1'
	else					gl dir `path2'
cd "$dir/20-910 Research TO - Ad Hoc Requests/COVID-19 Tracker - Weekly Deck/Data and Visualizations/COVID-19-cases-deaths"

* What date of beginning week?
loc dist_dt: di %td daily("`c(current_date)'","DMY")-6

*** OVERALL GRAPHS ---------------------------------------

* Import data
import delim "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv", clear

* Calculate new cases and deaths for U.S.
collapse (sum) cases deaths, by(date)
foreach v in cases deaths {
	g new_`v' = `v' - `v'[_n-1]
	replace new_`v' = `v' in 1
	drop `v'
}

* Set as time series 
// Days since 01/01/1960: https://www.timeanddate.com/date/duration.html
g t = _n + 21934
form t %td
tsset t

* Cases and deaths graph
foreach stat in cases deaths {
	tw ///
	bar new_`stat' t if t >= td(01mar2020), bcolor("251 209 000") vertical || ///
	bar new_`stat' t if t >= td(`dist_dt'), bcolor(black) vertical ||, ///
		ti("New `stat' by day in the U.S.") xti("") yti("") ///
		yla(, angle(0) nogrid form(%9.0fc)) ///
		xla(21975 "March" 22006 "April" 22036 "May" 22067 "June" 22097 "July" 22128 "August" 22159 "September" 22189 "October") ///
		ysiz(1) xsiz(2) ///
		graphregion(color(white)) bgcol(white) ///
		legend(order(1 "Since March" 2 "In the last week")) ///
		note("As of `c(current_date)'. Data sourced from The New York Times COVID-19 Data.", pos(6))
	gr export "`stat'_`c(current_date)'.png", replace
}

* Get numbers of cases and deaths for slide
collapse (sum) new* if t >= td(`dist_dt')