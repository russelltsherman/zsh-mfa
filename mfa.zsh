if chk::command "oathtool"
then

    mfa() {
        profile="${1}"
        file="${XDG_CONFIG_HOME}/mfa/${profile}.mfa"

        if [ -f "$file" ]
        then
            code="$(oathtool --base32 --totp "$(cat "$file")")"

            # push code into system clipboard if tty
            if [ -t 1 ] 
            then 
                if chk::osx
                then
                    echo "mfa code has been generated and pushed to system clipboard" >&2
                    echo "$code" | pbcopy 
                fi

                if chk::debian || chk::ubuntu
                then
                    echo "mfa code has been generated and pushed to system clipboard" >&2
                    echo "$code" | xclip -selection c 
                fi
            else
                echo $code
            fi

        elif [ -z "$profile" ]
        then
            if chk::command "fzf"
            then 
                selected=$(find ${XDG_CONFIG_HOME}/mfa/ -iname \*.mfa -maxdepth 1 -exec basename {} \; | sort| sed -e 's/\.mfa$//' | fzf)
                mfa $selected
            else
                echo "No MFA profile specified\n" >&2
                ls ${XDG_CONFIG_HOME}/mfa/ | sed -e 's/\.mfa$//'
            fi
        else
            echo "No MFA profile for $profile" >&2
        fi
    }

else
  echo "oathtool not found. execute 'mfa::install' to install it."

  mfa::install() {
    if chk::osx
    then
        brew install oath-toolkit
    fi

    if chk::debian || chk::ubuntu
    then
        sudo apt-get install -y oathtool
    fi
  }
fi