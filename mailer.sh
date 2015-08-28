#!/bin/bash
if [ -z $(which mail) ]; then
	echo mail is not installed, if you do not know how to do this
	echo you are not an admin but a email spammer..
	exit
fi
read -p "From address: " from
read -p "To address: " to
read -p "Subject: " subj
read -p "Message Body: " body
echo "Now sending your ($from) mail ($subj) to $to;$body" &&
echo "$body" | mail -s "$subj" -a "From:$from" $to
