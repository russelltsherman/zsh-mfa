
if chk::command "oathtool"
then

    mfa() {
        profile="${1}"
        file="${XDG_CONFIG_HOME}/mfa/${profile}.mfa"

        if [ -f "$file" ]
        then
            code="$(oathtool --base32 --totp "$(cat "$file")")"
            echo "$code" # output the code to screen
            echo "$code" | pbcopy # push code into system clipboard
        elif [ -z "$profile" ]
        then
            echo "No MFA profile defined" >&2
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
