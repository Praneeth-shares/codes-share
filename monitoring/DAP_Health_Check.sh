#!/bin/bash

# Initializes the report temporary file to empty in case there was one left behind
echo -n > DAP_Status_Report.txt

# Starts the header formatting of the report
echo "*******************************************" >> ./DAP_Health_Check_Report.txt
echo "*** CyberArk DAP LB VIP & Server Status ***" >> ./DAP_Health_Check_Report.txt
echo "*******************************************" >> ./DAP_Health_Check_Report.txt
echo "" >> ./DAP_Health_Check_Report.txt
var_startdate=$( date '+%F_%H:%M:%S' )
echo "Report generation started at: $var_startdate" >> ./DAP_Health_Check_Report.txt
#date >> ./DAP_Health_Check_Report.txt
#echo "**********************************************" >> ./DAP_Health_Check_Report.txt

echo "" >> ./DAP_Health_Check_Report.txt
echo "*****************************" >> ./DAP_Health_Check_Report.txt
echo "******* DAP Production ******" >> ./DAP_Health_Check_Report.txt
echo "*****************************" >> ./DAP_Health_Check_Report.txt

tmp_ServicesProdUp=0
tmp_ServicesProdDown=0
tmp_ServicesAccpUp=0
tmp_ServicesAccpDown=0

echo "" >> ./DAP_Health_Check_Report.txt
echo "*** DAP Production - Datapower & LB RestAPI Access & Services Status ***" >> ./DAP_Health_Check_Report.txt

tmp_response=`curl -ik https://intservices-dp1.accp.apptoapp.net/dap-read/health | grep -i 'HTTP/'`
echo "https://intservices-dp1.accp.apptoapp.net/dap-read - Datapower Accp Followers RestAPI Prod Access" >> ./DAP_Health_Check_Report.txt
if [[ "$tmp_response" == *"200"* ]]
then 
    echo "Service Up" >> ./DAP_Health_Check_Report.txt
    ((tmp_ServicesProdUp=tmp_ServicesProdUp+1))
else 
    echo "Service Down" >> ./DAP_Health_Check_Report.txt 
    ((tmp_ServicesProdDown=tmp_ServicesProdDown+1))
fi

tmp_response=`curl -ik https://intservices-dp1.accp.apptoapp.net/dap-write/health | grep -i 'HTTP/'`
echo "https://intservices-dp1.accp.apptoapp.net/dap-write - Datapower Accp Master RestAPI Prod Access" >> ./DAP_Health_Check_Report.txt
if [[ "$tmp_response" == *"200"* ]]
then 
    echo "Service Up" >> ./DAP_Health_Check_Report.txt
    ((tmp_ServicesProdUp=tmp_ServicesProdUp+1))
else 
    echo "Service Down" >> ./DAP_Health_Check_Report.txt 
    ((tmp_ServicesProdDown=tmp_ServicesProdDown+1))
fi

tmp_response=`curl -ik https://dap-read.apptoapp.net/health | grep -i 'HTTP/'`
echo "https://dap-read.apptoapp.net - LB Prod Followers VIP Services" >> ./DAP_Health_Check_Report.txt
if [[ "$tmp_response" == *"200"* ]] 
then 
    echo "Service Up" >> ./DAP_Health_Check_Report.txt
    ((tmp_ServicesProdUp=tmp_ServicesProdUp+1))
else 
    echo "Service Down" >> ./DAP_Health_Check_Report.txt 
    ((tmp_ServicesProdDown=tmp_ServicesProdDown+1))
fi

tmp_response=`curl -ik https://dap-write.apptoapp.net/health | grep -i 'HTTP/'`
echo "https://dap-write.apptoapp.net - LB Prod Master VIP Services" >> ./DAP_Health_Check_Report.txt
if [[ "$tmp_response" == *"200"* ]] 
then 
    echo "Service Up" >> ./DAP_Health_Check_Report.txt
    ((tmp_ServicesProdUp=tmp_ServicesProdUp+1))
else 
    echo "Service Down" >> ./DAP_Health_Check_Report.txt 
    ((tmp_ServicesProdDown=tmp_ServicesProdDown+1))
fi

echo "" >> ./DAP_Health_Check_Report.txt
echo "" >> ./DAP_Health_Check_Report.txt
echo "NOTICE: PamEng team no need to review the lines below." >> ./DAP_Health_Check_Report.txt
echo "        Only review the lines above, all services should be UP." >> ./DAP_Health_Check_Report.txt
echo "        If any services is down contact Sergio via Whatsapp." >> ./DAP_Health_Check_Report.txt
echo "" >> ./DAP_Health_Check_Report.txt
echo "" >> ./DAP_Health_Check_Report.txt

#tmp_response=curl -ik https://dap-write.apptoapp.net/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt

#tmp_response=`curl -ik https://dap-write.apptoapp.net/health | grep -i 'HTTP/'`
#tmp_role=`curl -ik https://dap-write.apptoapp.net/health | grep -i 'HTTP/'`


#tmp_response=`curl -ik https://pshklaaa9885.dsglobal.org/info | grep -i 'role'`
#[root@pstrlaac9247 ~]# if [[ "$tmp_response" == *"standby"* ]]; then echo "Wawawiwa"; fi



#if [[ "$tmp_response" == *"200"* ]]; then echo "Services Up" >> ./DAP_Health_Check_Report.txt; fi
#if [[ "$tmp_response" == *"502"* ]]; 

#then echo "Standby Role response" >> ./DAP_Health_Check_Report.txt; fi
echo "*** DAP - Production Servers - HTTPS Status ***" >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9883.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9883.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9884.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9884.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9885.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9885.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
echo "https://pstrlaaa9731.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pstrlaaa9731.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9939.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9939.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9940.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9940.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
echo "https://pstrlaaa9701.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pstrlaaa9701.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
echo "https://pstrlaaa9709.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pstrlaaa9709.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt


echo "" >> ./DAP_Health_Check_Report.txt
echo "*** DAP - Production Servers - Standby & Follower Replication Status ***" >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9884.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9884.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9885.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9885.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
echo "https://pstrlaaa9731.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pstrlaaa9731.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9939.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9939.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
echo "https://pshklaaa9940.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9940.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
echo "https://pstrlaaa9701.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pstrlaaa9701.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
echo "https://pstrlaaa9709.dsglobal.org" >> ./DAP_Health_Check_Report.txt
curl -ik https://pstrlaaa9709.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt

echo "" >> ./DAP_Health_Check_Report.txt
echo "*** DAP - Production Servers - Master Streaming Status ***" >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9883.dsglobal.org/health | grep -i 'application_name' >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9883.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
curl -ik https://pshklaaa9883.dsglobal.org/health | grep -i 'replication_lag_bytes' >> ./DAP_Health_Check_Report.txt


#echo "" >> ./DAP_Health_Check_Report.txt
#echo "*****************************" >> ./DAP_Health_Check_Report.txt
#echo "******* DAP Acceptance ******" >> ./DAP_Health_Check_Report.txt
#echo "*****************************" >> ./DAP_Health_Check_Report.txt


#echo "" >> ./DAP_Health_Check_Report.txt
#echo "*** DAP - Acceptance Servers - HTTPS Status ***" >> ./DAP_Health_Check_Report.txt
#echo "https://dap-write.accp.apptoapp.net" >> ./DAP_Health_Check_Report.txt
#curl -ik https://dap-write.accp.apptoapp.net/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
#echo "https://dap-read.accp.apptoapp.net" >> ./DAP_Health_Check_Report.txt
#curl -ik https://dap-read.accp.apptoapp.net/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9625.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9625.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9627.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9627.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9628.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9628.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9660.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9660.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9664.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9664.dsglobal.org/health | grep -i 'HTTP/' >> ./DAP_Health_Check_Report.txt


#echo "" >> ./DAP_Health_Check_Report.txt
#echo "*** DAP - Acceptance Servers - Standby & Follower Replication Status ***" >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9627.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9627.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9628.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9628.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9660.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9660.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
#echo "https://astrlaaa9664.dsglobal.org" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9664.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Status_Report.tx

#echo "" >> ./DAP_Health_Check_Report.txt
#echo "*** DAP - Production Servers - Master Streaming Status ***" >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9625.dsglobal.org/health | grep -i 'application_name' >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9625.dsglobal.org/health | grep -i 'streaming' >> ./DAP_Health_Check_Report.txt
#curl -ik https://astrlaaa9625.dsglobal.org/health | grep -i 'replication_lag_bytes' >> ./DAP_Health_Check_Report.txt

echo "" >> ./DAP_Health_Check_Report.txt
var_finishdate=$( date '+%F_%H:%M:%S' )
echo "Report generation finished at: $var_finishdate" >> ./DAP_Health_Check_Report.txt

echo "Prod Services UP: $tmp_ServicesProdUp"; echo "Prod Service Down: $tmp_ServicesProdDown" | mail -r PSM_Cyber-Ark@voya.com -s "DAP Health Check Report" -a DAP_Health_Check_Report.txt hemant.chandani@voya.com susmita.das@voya.com NagaRaju.Bhimaneni@voya.com VenkataSudheer.Tanjavuru@voya.com Sergio.Bascon@voya.com Srikanth.Kamarthy@voya.com PAMEngineering@voya.com

#cat ./DAP_Health_Check_Report.txt

rm ./DAP_Health_Check_Report.txt


