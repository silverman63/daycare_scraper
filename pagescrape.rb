def cleanup(data)
	def filter(datum)
		return String(datum).gsub(/[^\w\s\-\/]/, "").gsub(/\r?\n|\r|\t/,"").gsub(/\s+/, " ").gsub(/<[^>]*>/, "")
	end
	data.each do |key, value|
		if value.class == Hash
			data[key] = cleanup(value)
		elsif value.class == Array
			value.each do |val|
				cleanup(val)
			end
		else
			data[key] = filter(value)
		end
	end
end

def pagescrape(page)
	
	daycare = {}

	# basic info

	infoBoxes = page.search('.projectBox')

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
	daycare['certifiedToAdministerMedication'] = moreboxData[6].search('h5')[1].text
	daycare['yearsOperating'] = moreboxData[7].search('h5')[1].text

	#performanceHistorySections = page.search('.row-fluid .span12 .dashWidget ul.nav.nav-tabs li')


	# info related to latest inspection
	
	latestSections = page.search('#4 table tr table')
	
	if !latestSections.empty? 
		daycare['hasInspections'] = true
		daycare['latestInspection'] = {}
		latestInspectionInfo = latestSections[0]
		infractionTable = latestSections[1]

		latestInspectionData = latestInspectionInfo.search('tr')
		daycare['latestInspection']['date'] = latestInspectionData[0].search('td')[0].text
		daycare['latestInspection']['result'] = latestInspectionData[1].search('td')[0].text

		tableHeaders = infractionTable.search('table tr.odd th')
		headers = []
		tableHeaders.each do |header|
			headers.push(header.text)
		end

		currentInfractions = infractionTable.search('table tr.even')
		if currentInfractions.length == 1 and currentInfractions[0].text.include?('There were no new violations observed at the time of this inspection/visit.')
			currentInfractions = []
		end

		daycare['latestInspection']['numInfractions'] = currentInfractions.length

		daycare['latestInspection']['infractions'] = []
		currentInfractions.each do |infract|
			data = {}
			i = 0
			sections = infract.search('td')
			sections.each do | section|
				sectionContent = String(section.text).gsub(/[^\w\s\-\/]/, "").gsub(/\r?\n|\r/,"")
				data[headers[i]] = sectionContent
				i += 1
			end
			daycare['latestInspection']['infractions'].push(data)
		end

		# puts "daycare has #{ daycare['latestInspection']['numInfractions'] } violations"

	else
		daycare['hasInspections'] = false
		daycare['latestInspection'] = {}
		# puts "daycare has had no inspections"
		daycare['latestInspection']['date'] = nil
		daycare['latestInspection']['result'] = nil
		daycare['latestInspection']['infractions'] = nil
		daycare['latestInspection']['numInfractions'] = nil
	end


	# older inspections
	if !latestSections.empty? 
		inspectionsTable = page.search('#5 > div.accordion')[0]
		inspections = inspectionsTable.search('.accordion')
		puts "num inspections is #{ inspections.length }"
	end


	cleanup(daycare)

	return daycare

end