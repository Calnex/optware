# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

if [ -f ~/.timezone ]; then
  export TZ=$(cat ~/.timezone)
fi

mesg n

# Calnex additions
#
HOSTALIASES=/opt/etc/hostaliases
