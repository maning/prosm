#!/usr/bin/env bash

user=$1
#todo gender=$2
#MapboxAccessToken

echo "Looking back ..."
curl -s http://hdyc.neis-one.org/users/$user > "$user".json
cat "$user".json | jq .contributor.img | xargs curl -s -L -A "Mozilla/5.0 (compatible; MSIE 7.01; Windows NT 5.0)" | convert - jpg:- | jp2a --width=42 - > img.txt

echo "Weaving the story ..."
sleep 2
since=`cat "$user".json |  jq .contributor.since -r | tail -c 5`
now=`date +%Y`
years=`expr "$now" - "$since"`
flat=`cat "$user".json |  jq '.node.f_lat' -r`
flon=`cat "$user".json |  jq '.node.f_lon' -r` 
fedit=`mapbox geocoding --reverse [$flon,$flat] --place-type region |  jq '.features | .[].text' -r`
fdate=`cat "$user".json |  jq '.node.f_tstamp' -r | cut -d' ' -f1,3`
mnodes=`cat "$user".json |  jq '.nodes.m' -r`
cnodes=`cat "$user".json |  jq '.nodes.c' -r`
dnodes=`cat "$user".json |  jq '.nodes.d' -r`
mways=`cat "$user".json |  jq '.ways.m' -r`
dways=`cat "$user".json |  jq '.ways.d' -r`
cways=`cat "$user".json |  jq '.ways.c' -r`
totaledits=`expr "$mnodes" + "$cnodes" + "$dnodes" + "$dways" + "$cways" + "$mways"` 
maineditor=`cat $user.json | jq .changesets.editors -r | tr ';' '\n' | sort -t= -k+2 -n -r | sed 's/[=].*$//' | sed -n 1,1p`
activemappingyear=`cat $user.json | jq .changesets.mapping_days -r | tr ';' '\n' | sort -t= -k+2 -n -r | sed 's/[=].*$//' | sed -n 1,1p`
othereditor=`cat $user.json | jq .changesets.editors -r | tr ';' '\n' | sort -t= -k+2 -n -r | sed 's/[=].*$//' | sed -n 2,3p | tr -s '\n' ', '`
countries=`cat $user.json |  jq '.countries.countries' -r | tr ';' '\n' | sed 's/[=].*$//' | sed -n 1,5p  |tr '\n' ', '`
othercountries=`cat $user.json | jq '.countries.countries' | tr ';' '\n' | sed 's/[=].*$//' | sed -n 6,200p | wc -l `
maxday=`cat $user.json | jq .changesets.days -r | tr ',' '\n' | awk '$1 > max {max=$1; maxline=$0}; END{ print max}'`
maxdayofweek=`cat $user.json | jq .changesets.days -r | tr ',' '\n' | grep -n "$maxday" |  grep -Eo '^[^:]+'`

echo "Hi! I am "$user"! "  > story.txt  
echo "I joined OpenStreetMap "$years" years ago."  >> story.txt  
echo "My first edit was in "$fedit" "in" "$fdate"." >> story.txt
echo "Since then, I edited, " >> story.txt
printf "%'.f" `echo "$totaledits"| sh round.sh` >> story.txt
echo " points and lines." >> story.txt
echo "Among them, are, " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.amenity -r | sh round.sh` >> story.txt
echo " public places, " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.building -r | sh round.sh` >> story.txt
echo " buildings, "  >> story.txt
printf "%'.f" `cat $user.json | jq .tags.highway -r | sh round.sh` >> story.txt
echo " roads, " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.natural -r | sh round.sh` >> story.txt
echo " natural areas, " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.boundary -r | sh round.sh` >> story.txt
echo " borders, " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.landuse -r | sh round.sh` >> story.txt
echo " landuse, " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.railway -r | sh round.sh` >> story.txt
echo " railways, " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.addr -r | sh round.sh` >> story.txt
echo " addresses, and " >> story.txt
printf "%'.f" `cat $user.json | jq .tags.leisure -r | sh round.sh` >> story.txt
echo " recreation areas.  " >> story.txt

echo "I was very active last "$activemappingyear", usually every, ">> story.txt
echo "Sunday.,Monday.,Tuesday.,Wednesday.,Thursday.,Friday.,Saturday." | \
    cut -d',' -f`expr "$maxdayofweek"` >> story.txt
echo "I love using "$maineditor", but I also edit with "$othereditor"." >> story.txt

echo "I improve the map of: \n \
     "$countries" and also in "$othercountries" countries." \
     >> story.txt

echo "Here we go ..."
echo "\n "
sleep 3
cat img.txt
echo "\n "
cat story.txt \
    | say --interactive=red

rm img.txt story.txt "$user".json
