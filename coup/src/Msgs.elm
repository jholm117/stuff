module Msgs exposing (..)

import Http
import Navigation exposing (Location)
import Models exposing (Player, Name)
import RemoteData exposing (WebData)
import Pages.Dojo.Types as Dojo


type Msg
    = OnFetchPlayers (WebData (List Player))
    | OnLocationChange Location
    | ChangeLevel Player Int
    | OnPlayerSave (Result Http.Error Player)
    | UpdateNewName String -- text in form
    | AddNewPlayer -- Button clicked
    | OnPlayerAdded (Result Http.Error Player) -- reponse received
    | DeletePlayer Player
    | OnPlayerDeleted (Result Http.Error String)
    | DojoMsg Dojo.Msg
