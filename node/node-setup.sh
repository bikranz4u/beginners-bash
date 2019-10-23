
#!/bin/bash
############### Install Dependancies ##############
echo -e "$ylw Installing Pre-dependancies ....$rst"
echo -e "$ylw COMMAND>>$rst yum install yum-utils  curl wget gcc unzip bind-utils  -y "
#yum install yum-utils  curl wget gcc unzip bind-utils  -y


# Echo Color Codes for better readability
red="\e[91m"
rst="\e[0m"
grn="\e[92m"
ylw="\e[93m"


checkExecutionStatus() {
# Check if  Previous Step executed  successfully
    status=$?
    if [ "$status" == "0" ]; then
        echo -e "$grn Execution is successful.. $rst"
    else
        echo -e "$red Execution is unsuccessful.. $rst"
    fi
}


#Install node version manager using 'nvm'
echo -e "$ylw Install node version manager...$rst"
echo -e "$ylw COMMAND>>$rst curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
checkExecutionStatus

# Activate nvm
echo -e "$ylw Activate nvm ...$rst"
echo -e "$ylw COMMAND>>$rst sh ~/.nvm/nvm.sh"
chmod +x /root/.nvm/nvm.sh
source /root/.nvm/nvm.sh
checkExecutionStatus

#Use nvm to install the latest version of Node.js 
echo -e "$ylw Use nvm to install the latest version of Node.js ... $rst"
echo -e "$ylw COMMAND>>$rst nvm install node"
nvm install node
checkExecutionStatus

#Test that Node.js is installed and running correctly 
echo -e "$ylw Verify Node.js is installed and running correctly... $rst"
echo -e "$ylw COMMAND>>$rst node -e "console.log('Running Node.js ' + process.version)""
node_ver=$(node -e "console.log('Running Node.js ' + process.version)")
echo -e "$grn node_ver $rst"

#Installing PM2 process manager
echo -e "$ylw Installing PM2 process manager... &rst"
echo -e "$ylw COMMAND>>$rst npm install pm2 -g"
npm install pm2 -g
checkExecutionStatus

#Verify the pm2 installed 
pm2 list

