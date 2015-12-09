daycare_scraper
===============

Scrapes data about licensed daycare facilities from the NYC Dept of Mental Hygiene. All functions are encapsulated. 

To mess with data:
- $ irb
- $ require_relative 'scraper.rb'
- $ daycares = scraper
- you have the dataset

This ruby script iterates over each index page (showing 10 listings each), and POSTs to https://a816-healthpsi.nyc.gov/ChildCare/WDetail.do for each one. The WDetail.do page has a table of information about the daycare.  Mechanize is used to scrape this page, and export to CSV.

Created by the Project Care Day team. Taken from and modified from a base born out of the BetaNYC discussion group. http://www.meetup.com/betanyc/messages/archive/
