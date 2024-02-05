## Suicide Squad: Kill the Justice League EAC Manager

A script to disable EAC before running SS:KTJL


### Why?

Some trainers require EAC to be disabled before they can "hook" into the game. This is the case of the CheatHappens trainer for SS:KTJL.


### How?

The script is quite simple. When you open it, there's a short description of what it does.
If you select the only menu option there, it'll run the PowerShell script in an Admin PowerShell. 


### Why does it need an Admin PowerShell?

Unfortunately, it is required to move the `EasyAntiCheat_EOS.sys` file.


### Can I trust this script not to do anything bad?

I would say yes, but you should always check the contents of anything you run on your PC.


### What does the script do in detail?

0) The user chooses the only option in the main menu, "[1] Run Script".
1) Select the location of your SS:KTJL game folder
2) Choose a location to temporarily store the `EasyAntiCheat_EOS.sys` file.
3) The script will check if the game is running.
4) If the game is closed, it will continue.
5) Move the `EasyAntiCheat_EOS.sys` file and remove the contents of the `%appdata%\EasyAntiCheat` folder.
6) The script will then disable the internet when the user of the script presses **SPACE**.
7) Then it will open the game via Steam, `steam://rungameid/315210`.
8) It will detect when the game opens (when the SS:KTJL splash screen appears)
9) Then it'll turn the internet back on.
10) Then it will move the `EasyAntiCheat_EOS.sys` file back to it's original folder.
11) The script will automatically close after 30 seconds.


### Why doesn't it just remove EAC permanently?

I wanted it to re-enable the EAC, so that if you don't want to use a trainer the next time you want to play the game, it will just work as normal. 
Then, if you want to use a trainer again, you can just use this script.