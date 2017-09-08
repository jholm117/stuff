module Players.List exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (Player)
import RemoteData exposing (WebData)
import Routing exposing (playerPath)
import Componentry.AddPlayer exposing (addPlayerContainer)
import Componentry.DeletePlayer exposing (deletePlayerButton)

view : WebData (List Player) -> Html Msg
view response =
    div []
        [ nav
        , maybeList response
        , addPlayerContainer
        ]

maybeList : WebData (List Player) -> Html Msg
maybeList response =
    case response of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Success players ->
            list players

        RemoteData.Failure error ->
            text (toString error)


nav : Html Msg
nav =
    div
        []
        [ div
            [ class "bg-info left p2" ]
            [ text "Players" ] ]


list : List Player -> Html Msg
list players =
    div []
        [ table
            [ class "table table-sm table-hover" ]
            [ thead
                [ class "thead-default" ]
                [ tr
                    []
                    [ th [] []
                    , th [] [ text "Id" ]
                    , th [] [ text "Name" ]
                    , th [] [ text "Level" ]
                    , th [] [ text "Actions" ]
                     ]
                 ]
             , tbody [] (List.map playerRow players)
             ]
         ]


playerRow : Player -> Html Msg
playerRow player =
    tr []
        [ td [] [ deletePlayerButton player ]
        , td [] [ text player.id ]
        , td [] [ text player.name ]
        , td [] [ text (toString player.level) ]
        , td []
            [ editBtn player ]
        ]


editBtn : Player -> Html.Html Msg
editBtn player =
    let
        path =
            playerPath player.id

    in
        a
            [ class "btn btn-link"
            , href path
            ]
            [ i [ class "fa fa-pencil mr1" ] [], text "Edit" ]
