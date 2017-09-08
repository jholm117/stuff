module Componentry.DeletePlayer exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msgs exposing (..)
import Models exposing (Player)

deletePlayerButton : Player -> Html Msg
deletePlayerButton player =
    let
        message =
            DeletePlayer player
    in
        button
        [ class "close"
        , onClick message
        , type_ "button"
        , attribute "aria-label" "Close"]
        [ span
            [ attribute "aria-hidden" "true"
            , class "fa fa-remove" ]
            []]
