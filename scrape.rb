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

while offset < 2300 do #  < 10 do for testing
	puts "Offset: " + offset.to_s
	page = agent1.post 'https://a816-healthpsi.nyc.gov/ChildCare/SearchAction2.do?pager.offset=' + offset.to_s, form_data

	# text = page.body
	# puts "does text contain pickle?"
	# puts text.include?('PICKLE')
	# puts 'endcheck'

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

		data = {}

		infoBoxes = page2.search('.projectBox')

		firstbox = infoBoxes[0]
		firstboxData = firstbox.search('h5')
		data["type"] = firstboxData[0].text
		data["centerName"] = firstboxData[1].text
		data["permitHolder"] = firstboxData[2].text
		data["address"] = firstboxData[3].text
		address2 = firstboxData[4].text.split(',')
		data['borough'] = address2[0]
		data['zipCode'] = address2[1].split(" ")[-1]
		data['phone'] = firstboxData[5].text

		morebox = infoBoxes[1]
		moreboxData = morebox.search('tr')
		data['permitStatus'] = moreboxData[0].search('h5')[1].text
		data['permitNumber'] = moreboxData[1].search('h5')[1].text
		data['permitExpirationDate'] = moreboxData[2].search('h5')[1].text
		data['ageRange'] = moreboxData[3].search('h5')[1].text
		data['maximumCapacity'] = moreboxData[4].search('h5')[1].text
		data['siteType'] = moreboxData[5].search('h5')[1].text
		data['certrm ifiedToAdministerMedication'] = moreboxData[6].search('h5')[1].text
		data['yearsOperating'] = moreboxData[7].search('h5')[1].text

		
		# cleaning regex from old version?
		data.each do |datum|
			datum[1].gsub(/[^\w\s\-\/]/, "").gsub(/\r?\n|\r/,"")
			# output.print(datum[1])
			# output.print(",")
		end

		#output.print("\n")		

	end

offset = offset + 10

end


