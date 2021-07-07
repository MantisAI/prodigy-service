.env: .envrc
	sed -e "/export/!d" -e "s/export //g" $< > $@ 
