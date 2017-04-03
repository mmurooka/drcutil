source config.sh
cd $SRC_DIR

fetch_log() {
    for dir_name in $@; do
	if [ ! -e $dir_name ]; then
	    continue
	fi
        cd "$dir_name"
        echo -n > $SRC_DIR/${dir_name}.diff
        URL=$(git config --get remote.origin.url)
        LOCAL_ID=$(git log -1 HEAD --pretty=format:"%H")
        git fetch
        git log origin HEAD --pretty=format:"%H,%h" | while read line
        do
            REMOTE_ID=$(echo "${line}" | cut -d "," -f 1)
            if [ $REMOTE_ID == $LOCAL_ID ]; then
                break
            fi
            SHORT_ID=$(echo "${line}" | cut -d "," -f 2)
            echo "${dir_name},$SHORT_ID,${URL%.git}/commit/$REMOTE_ID" >> $SRC_DIR/${dir_name}.diff
        done
        cd ..
    done
}

fetch_log_nolink() {
    for dir_name in $@; do
	if [ ! -e $dir_name ]; then
	    continue
	fi
        cd "$dir_name"
        echo -n > $SRC_DIR/${dir_name}.diff
        URL=$(git config --get remote.origin.url)
        LOCAL_ID=$(git log -1 HEAD --pretty=format:"%H")
        git fetch
        git log origin HEAD --pretty=format:"%H,%h" | while read line
        do
            REMOTE_ID=$(echo "${line}" | cut -d "," -f 1)
            if [ $REMOTE_ID == $LOCAL_ID ]; then
                break
            fi
            SHORT_ID=$(echo "${line}" | cut -d "," -f 2)
            echo "${dir_name},$SHORT_ID," >> $SRC_DIR/${dir_name}.diff
        done
        cd ..
    done
}

fetch_log_nolink_noverify() {
    for dir_name in $@; do
	if [ ! -e $dir_name ]; then
	    continue
	fi
        cd "$dir_name"
        echo -n > $SRC_DIR/${dir_name}.diff
        #URL=$(git config --get remote.origin.url)
        URL=https://github.com/s-nakaoka/choreonoid.git
        LOCAL_ID=$(git log -1 HEAD --pretty=format:"%H")
        GIT_SSL_NO_VERIFY=1 git fetch
        git log origin HEAD --pretty=format:"%H,%h" | while read line
        do
            REMOTE_ID=$(echo "${line}" | cut -d "," -f 1)
            if [ $REMOTE_ID == $LOCAL_ID ]; then
                break
            fi
            SHORT_ID=$(echo "${line}" | cut -d "," -f 2)
            #echo "${dir_name},$SHORT_ID," >> $SRC_DIR/${dir_name}.diff
            #echo "${dir_name},$SHORT_ID,${URL%.git}/commit/$REMOTE_ID" >> $SRC_DIR/${dir_name}.diff
	    echo "${dir_name},$SHORT_ID,https://www.choreonoid.org/redmine/projects/choreonoid/repository/revisions/$REMOTE_ID/diff" >> $SRC_DIR/${dir_name}.diff
        done
        cd ..
    done
}

fetch_log "openhrp3" "hrpsys-base" "state-observation" "sch-core" "HRP2" "HRP2KAI" "HRP5P" "hrpsys-private" "hrpsys-state-observation" "hmc2" "hrpsys-humanoid"

if [ "$INTERNAL_MACHINE" -eq 0 ]; then
    fetch_log_nolink_noverify "choreonoid"
    fetch_log "trap-fpe"

    if [ -e choreonoid/ext ]; then
	cd choreonoid/ext
	fetch_log "hrpcnoid"
	cd ../..
    fi
else
    fetch_log "flexiport" "hokuyoaist" "rtchokuyoaist"
fi
