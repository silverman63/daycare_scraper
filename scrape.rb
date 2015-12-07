require 'rubygems'
require 'mechanize'
require 'csv'

agent1 = Mechanize.new
agent2 = Mechanize.new

fields = "centerName,permitHolder,address,borough,phone,zipCode,permitNumber,permitExpirationDate,permitStatus,ageRange,maximumCapacity,certifiedToAdministerMedication,siteType".split(',')

# output = File.new("output2.csv","w")
# output.print("centerName,permitHolder,address,borough,phone,zipCode,permitNumber,permitExpirationDate,permitStatus,ageRange,maximumCapacity,certifiedToAdministerMedication,siteType")
# output.print("\n")

offset = 0

# do initial pageview
form_data = {
	linkPK:0,
	pageroffset:0,
	getNewResult:true,
	progTypeValues: '', 
	search:1, 
	facilityName: '', 
	borough: '', 
	permitNo: '', 
	neighborhood: '', 
	zipCode: '' 
}
page = agent1.post 'https://a816-healthpsi.nyc.gov/ChildCare/SearchAction2.do'
form = page.forms.first
page = form.submit
agent1.cookie_jar.save_as 'cookies', :session => true, :format => :yaml

daycares = []

while offset < 2300 do #  < 10 do for testing
	puts "Offset: " + offset.to_s
	page = agent1.post 'https://a816-healthpsi.nyc.gov/ChildCare/SearchAction2.do?pager.offset=' + offset.to_s, form_data

	links = page.search('tr.gradeX.odd a')

	links.each do |link|

		id = link.to_s()
		id = id.split('redirectHistory(')[1]
		id = id[0,10]
		id = id.scan(/"([^"]*)"/)
		# puts id

		agent2.cookie_jar = agent1.cookie_jar

		idString = 'linkPK=' + id[0][0].to_s
		# puts idString

		page2 = agent2.post 'https://a816-healthpsi.nyc.gov/ChildCare/WDetail.do', idString ,({'Content-Type' => 'application/x-www-form-urlencoded'})

		daycare = {}

		infoBoxes = page2.search('.projectBox')

		firstbox = infoBoxes[0]
		firstboxData = firstbox.search('h5')
		daycare["type"] = firstboxData[0].text
		daycare["centerName"] = firstboxData[1].text
		daycare["permitHolder"] = firstboxData[2].text
		daycare["address"] = firstboxData[3].text
		address2 = firstboxData[4].text.split(',')
		daycare['borough'] = address2[0]
		daycare['zipCode'] = address2[1].split(" ")[-1]
		daycare['phone'] = firstboxData[5].text

		morebox = infoBoxes[1]
		moreboxData = morebox.search('tr')
		daycare['permitStatus'] = moreboxData[0].search('h5')[1].text
		daycare['permitNumber'] = moreboxData[1].search('h5')[1].text
		daycare['permitExpirationDate'] = moreboxData[2].search('h5')[1].text
		daycare['ageRange'] = moreboxData[3].search('h5')[1].text
		daycare['maximumCapacity'] = moreboxData[4].search('h5')[1].text
		daycare['siteType'] = moreboxData[5].search('h5')[1].text
		daycare['certrm ifiedToAdministerMedication'] = moreboxData[6].search('h5')[1].text
		daycare['yearsOperating'] = moreboxData[7].search('h5')[1].text

		
		daycare.each do |datum|
			# cleaning regex from old version
			datum[1].gsub(/[^\w\s\-\/]/, "").gsub(/\r?\n|\r/,"")
			puts datum[0] + ": " + datum[1]
			# output.print(datum[1])
			# output.print(",")
		end

		#output.print("\n")		
		daycares.push(daycare)

	end

offset = offset + 10

end


