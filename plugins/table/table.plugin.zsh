function table() {
  case "$1" in
    flip)
      echo "（╯°□°）╯︵ ┻━┻ "
      ;;
    set)
      echo "┬─┬﻿ ノ( ゜-゜ノ)"
      ;;
    man)
      echo "(╯°Д°）╯︵ /(.□ . \)"
      ;;
    bear)
      echo "ʕノ•ᴥ•ʔノ ︵ ┻━┻"
      ;;
    jedi)
      echo "(._.) ~ ︵ ┻━┻"
      ;;
    pudgy)
      echo "(ノ ゜Д゜)ノ ︵ ┻━┻"
      ;;
    battle)
      echo "(╯°□°)╯︵ ┻━┻ ︵ ╯(°□° ╯)"
      ;;
    rage)
      echo "‎(ﾉಥ益ಥ）ﾉ﻿ ┻━┻"
      ;;
    herc)
      echo "(/ .□.)\ ︵╰(゜Д゜)╯︵ /(.□. \)"
      ;;
    *)
      echo "Unknown table"
      ;;
  esac
}
