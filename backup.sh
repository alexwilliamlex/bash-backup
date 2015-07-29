#!/bin/bash
# @author: Sébastien SERRE
# @mail: sebastien@thivinfo.com
# @url: www.sebastien-serre.fr
# License: GPL
#
# Backup directory constant
DST=/path/to/files/backup/storage
DSTDB=/path/to/files/backup/storage
DATE=`date +%d-%m-%Y`
ADRESS=yourmail@domain.tld

## Delete more than X days backup
#
echo "Start Cleaning : "`date "+%d-%m-%Y %T"` >> $DST/log
find $DST -type f -mtime +X | xargs -r rm # replace X by number of days you want to keep
find $DSTDB -type f -mtime +X |xargs -r rm # replace X by number of days you want to keep
echo "Stop Cleaning : "`date "+%d-%m-%Y %T"` >> $DST/log

## going to backup folders
#
echo "Start backup db : "`date "+%d-%m-%Y %T"` >> $DST/log
cd $DSTDB

for i in name_of_your_db_separated_by_a space; do

## Sauvegarde des bases de donnees en fichiers .sql
mysqldump --user=XXX --password=XXXXX $i > ${i}_`date +%D | sed 's;/;-;g'`.sql   #replace XXXX by useer and passord to access to mysql

## Compress to tar.bz2 (best rate)
tar jcf ${i}_`date "+%d-%m-%Y" | sed 's;/;-;g'`.sql.tar.bz2 ${i}_`date "+%d-%m-%Y" | sed 's;/;-;g'`.sql

## delete uncompressed backup
rm ${i}_`date "+%d-%m-%Y" | sed 's;/;-;g'`.sql
done

echo "End backup db : "`date "+%d-%m-%Y %T"` >> $DST/log
echo "Start Copy : "`date "+%d-%m-%Y %T"` >> $DST/log
cd $DST
if [ ! -d "$DST/files/temp" ]; then
	mkdir $DST/files/temp;
fi

#files backup; add path separated by a space
for i in path/to/file/to/backup path/to/file/to/backup;
			do
				cd $i;
    			folder=$(basename `pwd`);
    			rsync -az --delete-after $i $DST/files/temp/
				tar -zcf $DST/files/$folder-$DATE.tar.gz $DST/files/temp/$folder
			done

			echo "End Copy : "`date "+%d-%m-%Y %T"` >> $DST/log

			#start rsync to a remote host
			echo "Start rsync : "`date "+%d-%m-%Y %T"` >> $DST/log
			rsync -e ssh -avz --delete-after ~/main/path/backup/ user@fdomain:~/path/to/store/backup/in/remote/host
			echo "Stop rsync : "`date "+%d-%m-%Y %T"` >> $DST/log
			echo "Backup terminé le "`date "+%d-%m-%Y %T"` $LOG | mail -s "backup du $DATE" $ADRESS
			echo "Mail envoyé : "`date "+%d-%m-%Y %T"` >> $DST/log

