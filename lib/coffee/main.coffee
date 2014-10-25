window._d = window.d = console?.log.bind(console) ? ->
urlfor = (query) -> "http://localhost:9000/search?q=#{escape query}"
autocomplete = _.memoize (query) ->
	d "Enqueueing '#{query}'"
	q.defer (cb) -> d3.json urlfor(query), (err, res) -> process(err, res); cb(null)

download = (text, fname='data.txt') ->
	text = JSON.stringify(text) unless typeof text == 'string'
	blob = new Blob [text], {type: 'text/plain;charset=utf-8'}
	saveAs(blob, fname)

allresults = [ ]
key 's', -> 
	if allresults.length
		download allresults, allresults[0].queryinfo.query
	else
		d 'No results to download.'

q = queue(10)
lowercasechars = (String.fromCharCode(c) for c in [72+25..72+50]) # [a..z]
process = (err, res) ->
	throw err if err?

	[query, completions, titles, unknown, {
		"google:suggesttype": suggesttype # QUERY, NAVIGATION
		"google:suggestrelevance": suggestrelevance
		"google:verbatimrelevance": verbatimrelevance # Seems to go from 1300 to 851.
	}] = res


	if completions.length
		d "Processing '#{query}'"
		queryinfo = {query, relevance: verbatimrelevance}
		results = d3.zip suggesttype, completions, suggestrelevance
			.filter (row) -> row[0] == 'QUERY'
			.map ([type, completion, relevance]) ->
				{queryinfo, type, completion, relevance}
		allresults.push results...
		d results

		canspace = false
		for {completion} in results
			tokens = completion[query.length..].split ' '
			for i in [0...tokens.length]
				autocomplete query + tokens[..i].join ' '

			canspace ||= completion[query.length] == ' '

		if canspace
			for c in lowercasechars
				autocomplete query + ' ' + c
		else if query[query.length - 1] == ' '
			for c in lowercasechars
				autocomplete query + c

	else
		d "No completions for '#{query}'"

	return

autocomplete "how do people "
