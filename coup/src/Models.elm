module Models exposing (..)

import RemoteData exposing (WebData)
import Pages.Dojo.State as Dojo
import Pages.Dojo.Types as DojoTypes


type alias Model =
    { players : WebData (List Player)
    , route : Route
    , newPlayerName : Name
    , numPlayers : Int
    , dojo : DojoTypes.Model
    }


initialModel : Route -> Model
initialModel route =
    { players = RemoteData.Loading
    , route = route
    , newPlayerName = ""
    , numPlayers = 0
    , dojo = Dojo.initialModel
    }


type alias PlayerId =
    String


type alias Name =
    String


type alias Player =
    { id : PlayerId
    , name : Name
    , level : Int
    }


type Route
    = PlayersRoute
    | PlayerRoute PlayerId
    | NotFoundRoute
    | HomeRoute
    | DojoRoute
