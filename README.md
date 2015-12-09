daycare_scraper
===============

## What it is
Scrapes data about licensed daycare facilities from the NYC Dept of Mental Hygiene. All functions are encapsulated. 

This ruby script iterates over each index page (showing 10 listings each), and POSTs to https://a816-healthpsi.nyc.gov/ChildCare/WDetail.do for each one. The WDetail.do page has a table of information about the daycare.  Mechanize is used to scrape this page, and export to CSV.


## To Use
(Make sure you have the mechanize gem)

To mess with data:
- $ irb
- $ require_relative 'scraper.rb'
- $ daycares = scraper
- you have the dataset

## Data in daycare objects
#### Basic
- type
- centerName
- permitHolder
- address
- borough
- zipCode
-phone

##### Business-related
- permitStatus
- permitNumber
- permitExpirationDate
- ageRange
- maximumCapacity
- siteType
- certifiedToAdministerMedication
- yearsOperating

#### Inspection-related
- hasInspections *(bool)*
- latestInspectionDate
- latestInspectionResult *(e.g. passed, didn't pass)*
- latestInspectionInfractions
- numberCurrentInfractions *(realize wrongly-named, but also probably doesn't need to exist?)*




Created by the Project Care Day team. Taken from and modified from a base born out of the BetaNYC discussion group. http://www.meetup.com/betanyc/messages/archive/
