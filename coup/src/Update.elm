module Update exposing (..)

import Msgs exposing (Msg)
import Models exposing (Model, Player, Name)
import Routing exposing (parseLocation)
import Commands exposing (savePlayerCmd, addPlayerCmd, deletePlayerCmd, fetchPlayers)
import RemoteData
import Response exposing (..)
import Pages.Dojo.State as Dojo


defaultLevel : Int
defaultLevel =
    2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnFetchPlayers response ->
            let
                list =
                    RemoteData.withDefault [] response

                num =
                    List.length list
            in
                ( { model | players = response, numPlayers = num }, Cmd.none )

        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        Msgs.UpdateNewName text ->
            ( { model | newPlayerName = text }, Cmd.none )

        ----------       PATCH
        Msgs.ChangeLevel player howMuch ->
            let
                updatedPlayer =
                    { player | level = player.level + howMuch }
            in
                ( model, savePlayerCmd updatedPlayer )

        Msgs.OnPlayerSave (Ok player) ->
            ( updatePlayer model player, Cmd.none )

        Msgs.OnPlayerSave (Err error) ->
            ( model, Cmd.none )

        ------------    POST
        Msgs.OnPlayerAdded (Ok player) ->
            ( addPlayer model player, Cmd.none )

        Msgs.OnPlayerAdded (Err error) ->
            ( model, Cmd.none )

        Msgs.AddNewPlayer ->
            let
                newPlayer =
                    makePlayer model.newPlayerName model.numPlayers
            in
                ( model, (addPlayerCmd newPlayer) )

        ------------    DELETE
        Msgs.DeletePlayer player ->
            ( model, deletePlayerCmd player )

        Msgs.OnPlayerDeleted (Ok string) ->
            ( { model | players = RemoteData.Loading }, fetchPlayers )

        Msgs.OnPlayerDeleted (Err error) ->
            ( model, Cmd.none )

        Msgs.DojoMsg subaction ->
            Dojo.update subaction model.dojo
                |> mapModel (\x -> { model | dojo = x })
                |> mapCmd Msgs.DojoMsg


updatePlayer : Model -> Player -> Model
updatePlayer model updatedPlayer =
    let
        pick currentPlayer =
            if updatedPlayer.id == currentPlayer.id then
                updatedPlayer
            else
                currentPlayer

        updatePlayerList players =
            List.map pick players

        updatedPlayers =
            RemoteData.map updatePlayerList model.players
    in
        { model | players = updatedPlayers }


addPlayer : Model -> Player -> Model
addPlayer model addedPlayer =
    let
        updatePlayerList players =
            players ++ [ addedPlayer ]

        updatedPlayers =
            RemoteData.map updatePlayerList model.players

        num =
            model.numPlayers + 1
    in
        { model | players = updatedPlayers, numPlayers = num }


makePlayer : Name -> Int -> Player
makePlayer playerName numPlayers =
    { id = toString (numPlayers + 1)
    , name = playerName
    , level = defaultLevel
    }


deletePlayer : Model -> Player -> Model
deletePlayer model deletedPlayer =
    let
        isNotDeletedPlayer player =
            player /= deletedPlayer

        updatePlayerList players =
            List.filter isNotDeletedPlayer players

        updatedPlayers =
            RemoteData.map updatePlayerList model.players
    in
        { model | players = updatedPlayers, numPlayers = model.numPlayers - 1 }
