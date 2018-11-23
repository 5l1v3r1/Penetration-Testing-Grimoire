#!/bin/bash
# OpenSSL .enc file decryption cracking script
# 2018 WeakNet Labs, Douglas Berdeaux, weaknetlabs@gmail.com
# ./opensslDecrypt.sh (WORDLIST) (FILE TO CRACK) (CIPHER)
wordlist=$1
encryptedFile=$2
cipher=$3
printf "\nOpenSSLDecrypt Brute Force Tool.\n\n[*] Destroying and Creating temporary directory, ./opensslDecryptOutput\n"
rm -rf opensslDecryptOutput
mkdir opensslDecryptOutput
count=0
#for passwd in $(cat $wordlist)
while read -r passwd
 do
  let "count++"
  passwd=$(echo $passwd | sed 's/[^0-9A-Za-z]//g') # remove all but alpha/num
  if [[ $passwd != "" ]] # we need an actual password to try
   then # Get the decrypted version:
    result=$(openssl enc -$cipher -d -a -in $encryptedFile -out opensslDecryptOutput/${passwd}.decrypted -d -pass pass:"$passwd" 2>/dev/stdout| head -n 1)
    # openssl enc -d -aes128 -salt -in drupal.txt -out opensslDecryptOutput/drupal.txt.decrypt -k friends | head -n 1
    if [[ $result != 'bad decrypt' ]]; # It wasn't a failure according to openSSL
     then
      if [[ -f "opensslDecryptOutput/${passwd}.decrypted" ]] # does the file exist?
       then
	#printf "[*] Trying: $passwd\n"; # DEBUG
        resultTest=$(file opensslDecryptOutput/${passwd}.decrypted | grep ASCII | wc -l)
        if [[ $resultTest -eq 1 ]]
         then
          printf "\n\n[!] Possible Passwd Found !!\nPASSWD: $passwd\n\n"
        fi
      else
       printf "[!] Could not create a decrypted file. Something went wrong with the input.\n[*] Error: $result\n\n"
       exit 1;
      fi
     fi
    if [[ $result == 'bad magic number' ]]; # the file is not an .enc file.
     then 
      printf "[!] Not an encrypted file. Is this an encoded encrypted file?\n";
      exit 1 # EXIT hard here
    fi
    rm opensslDecryptOutput/${passwd}.decrypted # remove it.
  fi
  if [[ $((count % 1000)) -eq 0 ]]
   then
    printf "[*] $count Passwords tried. ($passwd)\n"
  fi
done < $wordlist
