
#!/usr/bin/env sh

partition=$1

while :
do
	info=$(df | grep "$partition")
	echo \
		$(echo "$info" | awk '{printf "%s", $5}')
	sleep $2
done
