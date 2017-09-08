module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Msgs exposing (Msg)
import Models exposing (PlayerId, Player)
import RemoteData



fetchPlayers : Cmd Msg
fetchPlayers =
    Http.get fetchPlayersUrl playersDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchPlayers

fetchPlayersUrl : String
fetchPlayersUrl =
    "http://localhost:4000/players"

playersDecoder : Decode.Decoder (List Player)
playersDecoder =
    Decode.list playerDecoder



playerDecoder : Decode.Decoder Player
playerDecoder =
    decode Player
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "level" Decode.int


playerUrl : PlayerId -> String
playerUrl playerId =
    "http://localhost:4000/players/" ++ playerId

--PATCH
updatePlayerRequest : Player -> Http.Request Player
updatePlayerRequest player =
    Http.request
        { body = playerEncoder player |> Http.jsonBody
        , expect = Http.expectJson playerDecoder
        , headers = []
        , method = "PATCH"
        , timeout = Nothing
        , url = playerUrl player.id
        , withCredentials = False
        }
--POST
addPlayer : Player -> Http.Request Player
addPlayer player =
    Http.post fetchPlayersUrl (playerEncoder player
        |> Http.jsonBody) playerDecoder

--DELETE
deletePlayerRequest : Player -> Http.Request String
deletePlayerRequest player =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = playerUrl player.id
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False }


--UPDATE
savePlayerCmd : Player -> Cmd Msg
savePlayerCmd player =
    updatePlayerRequest player
        |> Http.send Msgs.OnPlayerSave

--ADD
addPlayerCmd : Player -> Cmd Msg
addPlayerCmd player =
    addPlayer player
        |> Http.send Msgs.OnPlayerAdded

--REMOVE
deletePlayerCmd : Player -> Cmd Msg
deletePlayerCmd player =
    deletePlayerRequest player
        |> Http.send Msgs.OnPlayerDeleted

playerEncoder : Player -> Encode.Value
playerEncoder player =
    let
        attributes =
            [ ( "id", Encode.string player.id )
            , ( "name", Encode.string player.name )
            , ( "level", Encode.int player.level )
            ]
    in
        Encode.object attributes
