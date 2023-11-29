function down4me() {
	#about 'checks whether a website is down for you, or everybody'
	#param '1: website url'
	#example '$ down4me http://www.google.com'
	#group 'base'
	curl -Lvs "http://downforeveryoneorjustme.com/$1" | sed '/just you/!d;s/<[^>]*>//g'
}
