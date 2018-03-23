
## RasPi Install :

https://github.com/godarklight/DarkMultiPlayer/wiki/RasPi-Install

(Installed on my Orange Pi Win Plus - OS : Raspbian_server_For_win_A64_V0_1)



## DMP Linux Server Tools :

https://forum.kerbalspaceprogram.com/index.php?/topic/83603-dmp-linux-server-tools/

 
 :warning: `curl http://pastebin.com/raw.php?i=...` didn't work (now) with php and gives *`"HTTP/1.1 302 Moved Temporarily"`*

Use :
```
  curl -v http://pastebin.com/raw.php?i=
```
  or
```
  wget -q -O- http://pastebin.com/raw.php?i=
```

(And change in `dmpinstaller.sh`, in `getPBinScript()`)

```
...
function getPBinScript(){
    echo "Installing '$2'. File will be downloaded from ${PASTEBIN_API}$1"
     wget -q -O- ${PASTEBIN_API}$1 | tr -d '\r' > $2
    echo "Installed '$2'."
    echo
}
...
```
