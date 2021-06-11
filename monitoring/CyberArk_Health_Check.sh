#!/bin/bash

echo -n > ./CyberArk_Health_Check_Report.txt

echo "*************************************************************" >> ./CyberArk_Health_Check_Report.txt
echo  "CyberArk Daily Health Check Report for Linux & HTTP Servers" >> ./CyberArk_Health_Check_Report.txt
echo "*************************************************************" >> ./CyberArk_Health_Check_Report.txt
date >> ./CyberArk_Health_Check_Report.txt
echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Production PSMP servers: " >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh pjaxlcyb9050 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh pmpllcyb9050 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh pmpllaab9254 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh pmpllaab9255 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
#echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh pjaxlaab9408 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
#echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh pjaxlaab9409 "hostname; echo ""; echo "Disk Usage details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status" >> ./CyberArk_Health_Check_Report.txt

#echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt
#echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt

#echo "" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt

echo "Acceptance PSMP servers: " >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

#ssh ajaxlaab9008 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh ajaxlcyb9000 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

#ssh ajaxlaab9007 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt

ssh ajaxlcyb9050 "hostname; echo ""; echo "Disk Usage Details"; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var; df -h | grep -i /opt; echo ""; echo "PSMP Service Status:"; /etc/init.d/psmpsrv status;" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt

echo "Disk Usage details of pmpllaaa5011 (OPM Server)" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo "Server Name: " >> ./CyberArk_Health_Check_Report.txt
ssh pmpllaaa5011 "hostname; echo ""; df -h | grep -i Filesystem; df -h | grep -i /var;" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt

echo "" >> ./CyberArk_Health_Check_Report.txt

echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt
echo             "PVWA Web Interfaces Results" >> ./CyberArk_Health_Check_Report.txt
echo "**********************************************" >> ./CyberArk_Health_Check_Report.txt

echo https://pmplwaaa9751.dsglobal.org: >> ./CyberArk_Health_Check_Report.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pmplwaaa9751.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./CyberArk_Health_Check_Report.txt

echo https://pjaxwaaa9857.dsglobal.org: >> ./CyberArk_Health_Check_Report.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pjaxwaaa9857.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./CyberArk_Health_Check_Report.txt

echo https://pmplwaaa9760.dsglobal.org: >> ./CyberArk_Health_Check_Report.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pmplwaaa9760.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./CyberArk_Health_Check_Report.txt

echo https://pjaxwaaa9850.dsglobal.org: >> ./CyberArk_Health_Check_Report.txt
ssh cyberark-psmp.apptoapp.org "curl -ik https://pjaxwaaa9850.dsglobal.org/PasswordVault/v10/logon/cyberark | grep -i 'HTTP/'" >> ./CyberArk_Health_Check_Report.txt

echo "****************************************" >> ./CyberArk_Health_Check_Report.txt

echo "" >> ./CyberArk_Health_Check_Report.txt

#echo -e "Hi All,\n"; echo "Please find the Attachment for CyberArk Daily Health Check Report for Linux and HTTP Servers"; echo ""; echo "Request you to Kindly Validate and if any issue found, Kindly Drop an email to: PAMEngineering@voya.com"; echo -e "\nThanks"; echo "PAMEngineering@voya.com"; echo "Technology Risk Security Management (TRSM), Voya Financial" | mail -r PSM_Cyber-Ark@voya.com -s "CybeArk Daily Health Check Report for Linux Servers" -a Daily_Health_Check_Status_Report.txt hemant.chandani@voya.com

echo "Please find the Attachment for CyberArk Daily Health Check Report for Linux and HTTP Servers. Request you to Kindly Validate and if any issue found, Kindly Drop an email to: PAMEngineering@voya.com" | mail -r PSM_Cyber-Ark@voya.com -s "CyberArk Daily Health Check Report -- Bash Script" -a Daily_Health_Check_Status_Report.txt hemant.chandani@voya.com susmita.das@voya.com NagaRaju.Bhimaneni@voya.com VenkataSudheer.Tanjavuru@voya.com Sergio.Bascon@voya.com Daniel.Tromp@voya.com Srikanth.Kamarthy@voya.com PAMEngineering@voya.com

cat ./CyberArk_Health_Check_Report.txt

rm ./CyberArk_Health_Check_Report.txt
