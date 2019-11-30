#!/bin/sh
# A menu driven shell script for Patch Installation and Roll Back
#
## ----------------------------------
# Step #1: Define variables
# ----------------------------------
date
#timestamp=$(date "+%Y-%m-%d-%T" | cut -d'-' -f4) # Hour:Minute:Sec
Date=$(date "+%Y-%m-%d")

proj_dir='/home/'
backup_dir='/home/backup'
# Echo Color Codes for better readability
red="\e[91m"
rst="\e[0m"
grn="\e[92m"
ylw="\e[93m"

# ----------------------------------
# Step #2: User defined function
# ----------------------------------
# pause(){
#   read -p "Press [Enter] key to continue..." fackEnterKey
# }

checkCopyStatus() {
    # Check if  copy is successful
    status=$?
    if [ "$status" -eq 0 ]; then
        echo -e "$grn copy is successful.. $rst"
    else
        echo -e "$red copy is unsuccessful.. $rst"
    fi

}

Status() {
    # Check if  command is successful
    status=$?
    if [ "$status" -eq 0 ]; then
        echo -e "$grn Executed successful.. $rst"
    else
        echo -e "$red Executed unsuccessful.. $rst"
    fi

}

# Unzip The Patch File

install() {
    echo -e "$ylw --------------- Available .zip Files -----------$rst"
    files=$(cd "$proj_dir" && ls -lsrt *.zip | tr -s ' ' ' ' | awk -F' ' '{print $NF}')
    echo "$files"
    echo -e "$ylw ------------------------------------------------$rst"
    echo -e "$grn Enter the Patch file to be deployed ... $rst"
    read -r filename </dev/tty
    echo -e "$ylw unzipping $filename ....$rst"
    unzip "$proj_dir"/"$filename" -d $proj_dir/
    if [ $? -eq 0 ]; then
        echo -e "$grn Unzip Executed successful.. $rst"
    else
        echo -e "$red Unzip is  unsuccessful..aborting.. $rst"
        exit 1
    fi
    name=$(echo $proj_dir/"$filename" | cut -f 1 -d '.' | awk -F'/' '{print $NF}')
    echo "$name" #TODO
}

backup() {
    echo -e "$ylw Creating a backup directory ...$rst"
    defaultTargetDirectory="Shaw_Backup_$(echo "$Date")"
    echo -e "$ylw Enter target build directory name $rst(Ex: ${defaultTargetDirectory}) :"
    read -r targetBackupDirectory </dev/tty
    # get target directory
    if [ -d "$backup_dir/$targetBackupDirectory" ]; then
        echo -e "$red Directory already exists ...Aborting $rst"
        exit 1
    else
        mkdir -p "$backup_dir"/"$targetBackupDirectory"
        Status
        echo -e "$grn Backup directory created .."

        input="$name/Filelist.txt"
        echo "------------------------------------------------"
        echo -e "$ylw The files to be updated $rst"
        echo "------------------------------------------------"
        display=$(cat $name/Filelist.txt)
        echo "$display"
        echo "------------------------------------------------"
        echo -e "$ylw Checking If files  are already exist on Project...we will take backup $rst"
        while IFS= read line || [ -n "$line" ]; do
            IFS='|'
            fileArr=($line)
            fullpath=$(echo "$line" | sed 's/|/\//g')
            echo "$fullpath"      #TODO
            echo "${fileArr[$@]}" #TODO
            if [ -f "$fullpath" ]; then
                directory_tobe_created="${fileArr[$@]}"
                echo "$directory_tobe_created"
                echo -e "$grn Creating Directory structure under $defaultTargetDirectory ..$rst"
                mkdir -p "${backup_dir}/${defaultTargetDirectory}/$directory_tobe_created"
                Status
                cp -rf "$fullpath" "${backup_dir}/${defaultTargetDirectory}/${directory_tobe_created}"
                checkCopyStatus
                srcFileChecksum=$(md5sum  "$fullpath" | cut -d' ' -f1)
                destchecksumfile=$("$fullpath" | awk -F"/" '{print $NF}' | cut -d' ' -f1)
                destFilechecksum=$(md5sum "${backup_dir}/${defaultTargetDirectory}/${directory_tobe_created}/$destchecksumfile" | cut -d' ' -f1)
                if [ "$srcFileChecksum" = "$destFilechecksum" ]; then
                    echo -e "$grn Source  and Destinations files are same $rst"
                else
                    echo -e " $red Files differ.... $rst"
                fi
                echo -e "$grn Backup Successful ...$rst"
            else
                echo -e "$fullpath $grn is a new file. $rst"
                echo $fullpath > ./NewFiles.txt
            fi

        done <"$input"
    fi

}

remove_existing_files() {
    echo -e "$red Will removing existing Files .... Please Confirm (yes/no) ?$rst"
    read -r input </dev/tty
    if [ "$input" = "yes" ] || [ "$input" = "y" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ] || [ "$input" = "Y" ]; then
        input="'$proj_dir'/'$name'/Filelist.txt"
        while IFS='\n' read -r line; do
            if [ -f "$line" ]; then
                echo -e "$ylw Checking If files  are already exist on Project...If So we will remove those files .. $rst"
                echo -e "$red removing $line   $rst"
                rm $line
            else
                echo -e "$grn file does not exist on application , It a new file. $rst)"
            fi
        done <"$input"
    else
        echo -e "$red We are aborting ...$rst "
        exit 1
    fi

}

install_new_patches() {
    echo -e "$red Will Updating application with  new Files .... Please Confirm (yes/no) ?$rst"
    read -r input </dev/tty
    if [ "$input" = "yes" ] || [ "$input" = "y" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ] || [ "$input" = "Y" ]; then
        input="'$proj_dir'/'$name'/Filelist.txt"
        while IFS='\n' read -r line; do
            cp -rf "$proj_dir"/"$name"/echo "$line" "$proj_dir"/"$line"
            checkCopyStatus
        done <"$input"
    else
        echo -e "$red We are aborting ...$rst "
        exit 1
    fi

}
one() {
    install
    backup
    echo -e " $grn We are proceeding for New Patch Installation ...Please Confirm (yes/no) ?$rst"
    read -r input </dev/tty
    if [ "$input" = "yes" ] || [ "$input" = "y" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ] || [ "$input" = "Y" ]; then
        #            echo -e "We are in Installtion"
        #check Project Directoryis present
        if [ ! -d "$proj_dir" ]; then
            echo "$proj_dir not present...exiting"
            exit 1
        else
            install_new_patches
            Status
            echo -e "$grn We are Done with installtion ....Exiting ... Please do Verification... $rsr" && sleep 5 && exit 0
        fi
        exit 0
    else
        echo -e "$red You have entered $input ...Aborting !!! $rst"
        exit 1 #unsucessful termination
    fi
}
# do something in two()
two() {
    echo -e "We are proceeding for Rollback ...Please Confirm (yes/no) ?"
    read -r input </dev/tty
    if [ "$input" = "yes" ] || [ "$input" = "y" ] || [ "$input" = "Yes" ] || [ "$input" = "YES" ] || [ "$input" = "Y" ]; then
        echo -e "We are in Rollback"
        exit 0
    else
        echo -e "$red You have entered $input ...Aborting !!! $rst"
        exit 1 #unsucessful termination
    fi
}

# function to display menus
show_menus() {
    clear
    echo -e "$ylw WARNING: This Script Can be Used for $rst $grn Patch Installation $rst and $red RollBack $rst, $ylw Please Choose Carefully !!! $rst"
    echo " "
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo " M A I N - M E N U"
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo "1. Install"
    echo "2. Rollback"
    echo "3. Exit"
}

# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options() {
    local choice
    read -p "Enter choice [ 1 - 3]: " choice
    case $choice in
    1) one ;;
    2) two ;;
    3) exit 0 ;; #sucessful termination
    *) echo -e "$red Invalid Choice ... $rst" && sleep 2 ;;
    esac
}

# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP SIGABRT

# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true; do
    show_menus
    read_options
done
