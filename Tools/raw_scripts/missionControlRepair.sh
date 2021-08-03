#!/bin/bash

mcxDisabled=$(defaults read com.apple.dock mcx-expose-disabled)

if [[ $mcxDisabled == 1 ]]
then
  defaults write com.apple.dock mcx-expose-disabled -bool FALSE
  killAll Dock
  echo "Lockdown browser changes your settings to lock down the computer during tests. I have undone the changes it did to mission control. However, the problem may re-occur if you use lockdown browser."
else
  echo "Tool was unable to identify issue automatically. The identification test may have been a false negative. Please check manually. Test Result: '$mcxDisabled'"
fi
