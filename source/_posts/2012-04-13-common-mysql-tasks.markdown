---
layout: post
title: "Common MySQL Tasks"
date: 2012-04-13 00:34
comments: true
categories: mysql
---

I'm pretty terrible at remembering some of the simpler MySQL tasks, so here are a few of the more common tasks I do on a regular basis that I keep written down so I don't forget them.

##Dump The MySQL Table

`mysqldump -u username -p -r my_output.sql my_database`

###Compress Output with 7zip using the PPMd Algorithm (Optional)

`7z a -t7z my_output.7z my_output.sql -m0=PPMd`

###Decompress Output with 7zip (Optional)

`7z e my_output.7z`

##Restore The MySQL Table

`mysql -u username -p my_database < my_output.sql` 

##Export Table as CSV From MySQL

`SELECT * INTO OUTFILE '/tmp/my_table_name.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '\\' LINES TERMINATED BY '\n' FROM my_table_name;`
