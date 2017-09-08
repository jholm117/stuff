module Pages.Dojo.Types exposing (..)

import Pages.Dojo.Menu as Menu
import Game.Types as Game


type alias Model =
    { game : Game.Model
    , menu : Menu.Model
    }


type Msg
    = GameMsg Game.Msg
    | MenuMsg Menu.Msg
