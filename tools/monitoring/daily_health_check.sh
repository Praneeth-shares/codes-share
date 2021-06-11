echo "*************************************************************" > ./output1.txt
echo  "CyberArk Daily Health Check Report for Linux & HTTP Servers" >> ./output1.txt
echo "*************************************************************" >> ./output1.txt
date >> ./output1.txt
echo "**********************************************" >> ./output1.txt
echo "Production PSMP servers: " >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh pjaxlcyb9050 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh pmpllcyb9050 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh pmpllaab9254 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh pmpllaab9255 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
#echo "Server Name: " >> ./output1.txt

ssh pjaxlaab9408 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
#echo "Server Name: " >> ./output1.txt

ssh pjaxlaab9409 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./output1.txt

#echo "Server Name: " >> ./output1.txt
#echo "**********************************************" >> ./output1.txt

#echo "" >> ./output1.txt

echo "**********************************************" >> ./output1.txt

echo "Acceptance PSMP servers: " >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh ajaxlaab9008 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh ajaxlcyb9000 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh ajaxlaab9007 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt

ssh ajaxlcyb9050 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./output1.txt

echo "**********************************************" >> ./output1.txt

echo "Disk Usage details of pmpllaaa5011 (OPM Server)" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo "Server Name: " >> ./output1.txt
ssh pmpllaaa5011 "hostname; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var;" >> ./output1.txt

echo "**********************************************" >> ./output1.txt

echo "" >> ./output1.txt

echo "**********************************************" >> ./output1.txt
echo             "PVWA Web Interfaces Results" >> ./output1.txt
echo "**********************************************" >> ./output1.txt

echo https://pmplwaaa9751.dsglobal.org: >> ./output1.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pmplwaaa9751.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./output1.txt

echo https://pjaxwaaa9857.dsglobal.org: >> ./output1.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pjaxwaaa9857.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./output1.txt

echo https://pmplwaaa9760.dsglobal.org: >> ./output1.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pmplwaaa9760.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./output1.txt

echo https://pjaxwaaa9850.dsglobal.org: >> ./output1.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pjaxwaaa9850.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./output1.txt


#curl -k https://pmplwaaa9751.dsglobal.org/passwordvault >> ./output1.txt

echo "****************************************" >> ./output1.txt

echo "" >> ./output1.txt

(echo -e "Hi All,\n"; echo "Please find the Attachment for CyberArk Daily Health Check Report for Linux and HTTP Servers"; echo ""; echo "Request you to Kindly Validate and if any issue found, Kindly Drop an email to: PAMEngineering@voya.com"; echo -e "\nThanks"; echo "PAMEngineering@voya.com"; echo "Technology Risk Security Management (TRSM), Voya Financial"; uuencode /etc/pam/output1.txt Daily_Health_Check_Results.doc) | mailx -s "CybeArk Daily Health Check Report for Linux and HTTP Servers" pamengineering@voya.com hemant.chandani@voya.com

#(echo -e "Hi All,\n"; echo "Please find the Attachment for CyberArk Daily Health Check Report for Linux and HTTP Servers"; echo ""; echo "Request you to Kindly Validate and if any issue found, Kindly Drop an email to: PAMEngineering@voya.com"; echo -e "\nThanks"; echo "PAMEngineering@voya.com"; echo "Technology Risk Security Management (TRSM), Voya Financial"; uuencode /etc/pam/output1.txt Daily__Health_Check_Results.doc) | mailx -s "CybeArk Daily Health Check Report for Linux and HTTP Servers" hemant.chandani@voya.com

#(echo -e "Hi All,\n"; echo "Please find the Attachment for CyberArk Daily Health Check Report for Linux and HTTP Servers"; echo ""; echo "Request you to Kindly Validate and if any issue found, Kindly Drop an email to: PAMEngineering@voya.com"; echo -e "\nThanks"; echo "PAMEngineering@voya.com"; echo "Technology Risk Security Management (TRSM), Voya Financial"; uuencode /etc/pam/output1.txt Daily__Health_Check_Results.txt) | mailx -s "CybeArk Daily Health Check Report for Linux and HTTP Servers" Daniel.Tromp@voya.com PAMEngineering@voya.com hemant.chandani@voya.com Sergio.Bascon@voya.com SathishKumar.Alishetty@voya.com NagaRaju.Bhimaneni@voya.com


#uuencode /etc/pam/output1.txt Daily__Health_Check_Results.doc | mailx -s "CybeArk Daily Health Check Report for Linux and HTTP Servers" hemant.chandani@voya.com


#uuencode /etc/pam/output1.txt Daily__Health_Check_Results.txt | mailx -s "CybeArk Daily Health Check Report for Linux and HTTP Servers" hemant.chandani@voya.com Sergio.Bascon@voya.com SathishKumar.Alishetty@voya.com NagaRaju.Bhimaneni@voya.com

#uuencode /etc/pam/output1.txt Daily__Health_Check_Results.txt | mailx -s "CybeArk Daily Health Check Report for Linux and HTTP Servers"  Daniel.Tromp@voya.com PAMEngineering@voya.com hemant.chandani@voya.com Sergio.Bascon@voya.com SathishKumar.Alishetty@voya.com NagaRaju.Bhimaneni@voya.com

cat ./output1.txt

#mail -s "Health Check Results - PSMP Servers" PAMEngineering@voya.com hemant.chandani@voya.com Sergio.Bascon@voya.com SathishKumar.Alishetty@voya.com NagaRaju.Bhimaneni@voya.com < /etc/pam/output1.txt

#mail -s "Health Check Results - PSMP Servers" hemant.chandani@voya.com < /etc/pam/output1.txt
